<?php

$base = dirname(__DIR__);
function w(string $path, string $contents): void
{
    $dir = dirname($path);
    if (! is_dir($dir)) {
        mkdir($dir, 0777, true);
    }
    file_put_contents($path, $contents);
    echo basename($path)."\n";
}

w("$base/app/Services/AuthService.php", <<<'PHP'
<?php

namespace App\Services;

use App\Contracts\Repositories\UserRepositoryInterface;
use App\Exceptions\DomainException;
use App\Models\Cart;
use App\Models\Member;
use App\Models\User;
use App\Models\UserSetting;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Password;
use Illuminate\Validation\ValidationException;

class AuthService
{
    public function __construct(private readonly UserRepositoryInterface $users)
    {
    }

    /**
     * @param  array{name:string,email?:string|null,phone?:string|null,password:string}  $data
     * @return array{user:User,token:string}
     */
    public function register(array $data): array
    {
        return DB::transaction(function () use ($data) {
            /** @var User $user */
            $user = $this->users->create([
                'name' => $data['name'],
                'email' => $data['email'] ?? null,
                'phone' => $data['phone'] ?? null,
                'password' => $data['password'],
            ]);

            Member::query()->create([
                'user_id' => $user->id,
                'display_name' => $data['name'],
            ]);

            UserSetting::query()->create([
                'user_id' => $user->id,
            ]);

            Cart::query()->create([
                'user_id' => $user->id,
            ]);

            $token = $user->createToken('mobile')->plainTextToken;

            return ['user' => $user->load(['member', 'settings']), 'token' => $token];
        });
    }

    /**
     * @return array{user:User,token:string}
     */
    public function login(string $identifier, string $password): array
    {
        $user = $this->users->findByIdentifier($identifier);

        if (! $user || ! Hash::check($password, $user->password)) {
            throw ValidationException::withMessages([
                'identifier' => ['The provided credentials are incorrect.'],
            ]);
        }

        $token = $user->createToken('mobile')->plainTextToken;

        return ['user' => $user->load(['member', 'settings']), 'token' => $token];
    }

    public function logout(User $user): void
    {
        $user->currentAccessToken()?->delete();
    }

    public function forgotPassword(string $email): string
    {
        $status = Password::sendResetLink(['email' => $email]);

        if ($status !== Password::RESET_LINK_SENT) {
            throw new DomainException(__($status), 422);
        }

        return __($status);
    }

    /**
     * @param  array{email:string,token:string,password:string}  $data
     */
    public function resetPassword(array $data): string
    {
        $status = Password::reset(
            [
                'email' => $data['email'],
                'password' => $data['password'],
                'password_confirmation' => $data['password'],
                'token' => $data['token'],
            ],
            function (User $user, string $password) {
                $user->forceFill(['password' => $password])->save();
                $user->tokens()->delete();
            }
        );

        if ($status !== Password::PASSWORD_RESET) {
            throw new DomainException(__($status), 422);
        }

        return __($status);
    }
}
PHP);

w("$base/app/Services/ProfileService.php", <<<'PHP'
<?php

namespace App\Services;

use App\Contracts\Repositories\UserRepositoryInterface;
use App\Exceptions\DomainException;
use App\Models\User;
use Illuminate\Support\Facades\Hash;

class ProfileService
{
    public function __construct(private readonly UserRepositoryInterface $users)
    {
    }

    public function me(User $user): User
    {
        return $user->load(['member', 'settings']);
    }

    public function updateProfile(User $user, array $data): User
    {
        $user = $this->users->update($user, array_filter([
            'name' => $data['name'] ?? null,
            'email' => $data['email'] ?? null,
            'phone' => $data['phone'] ?? null,
            'avatar_path' => $data['avatar_path'] ?? null,
        ], static fn ($v) => $v !== null));

        if (isset($data['name']) && $user->member) {
            $user->member->update(['display_name' => $data['name']]);
        }

        return $user->load(['member', 'settings']);
    }

    public function changePassword(User $user, string $current, string $new): void
    {
        if (! Hash::check($current, $user->password)) {
            throw new DomainException('Current password is incorrect.', 422, 'invalid_current_password');
        }

        $this->users->update($user, ['password' => $new]);
        $user->tokens()->where('id', '!=', $user->currentAccessToken()?->id)->delete();
    }
}
PHP);

w("$base/app/Services/SettingsService.php", <<<'PHP'
<?php

namespace App\Services;

use App\Contracts\Repositories\SettingsRepositoryInterface;
use App\Models\User;
use App\Models\UserSetting;

class SettingsService
{
    public function __construct(private readonly SettingsRepositoryInterface $settings)
    {
    }

    public function get(User $user): UserSetting
    {
        return $this->settings->forUser($user);
    }

    public function update(User $user, array $data): UserSetting
    {
        $setting = $this->settings->forUser($user);

        return $this->settings->update($setting, $data);
    }

    /** @return list<array{code:string,label:string}> */
    public function languages(): array
    {
        return [
            ['code' => 'en', 'label' => 'English'],
            ['code' => 'id', 'label' => 'Bahasa Indonesia'],
            ['code' => 'ar', 'label' => 'Arabic'],
            ['code' => 'zh', 'label' => 'Chinese'],
        ];
    }
}
PHP);

w("$base/app/Services/HomeFeedService.php", <<<'PHP'
<?php

namespace App\Services;

use App\Contracts\Repositories\CategoryRepositoryInterface;
use App\Contracts\Repositories\ProductRepositoryInterface;
use App\Contracts\Repositories\PromotionRepositoryInterface;

class HomeFeedService
{
    public function __construct(
        private readonly PromotionRepositoryInterface $promotions,
        private readonly CategoryRepositoryInterface $categories,
        private readonly ProductRepositoryInterface $products,
    ) {
    }

    /** @return array{promotions:mixed,categories:mixed,new_arrivals:mixed} */
    public function feed(): array
    {
        return [
            'promotions' => $this->promotions->activePromotions(),
            'categories' => $this->categories->activeRoots(),
            'new_arrivals' => $this->products->newArrivals(12),
        ];
    }
}
PHP);

w("$base/app/Services/ProductService.php", <<<'PHP'
<?php

namespace App\Services;

use App\Contracts\Repositories\FavoriteRepositoryInterface;
use App\Contracts\Repositories\ProductRepositoryInterface;
use App\Contracts\Repositories\ReviewRepositoryInterface;
use App\Models\Product;
use App\Models\User;
use Illuminate\Contracts\Pagination\LengthAwarePaginator;

class ProductService
{
    public function __construct(
        private readonly ProductRepositoryInterface $products,
        private readonly FavoriteRepositoryInterface $favorites,
        private readonly ReviewRepositoryInterface $reviews,
    ) {
    }

    public function search(array $filters, int $perPage = 15): LengthAwarePaginator
    {
        return $this->products->search($filters, $perPage);
    }

    public function show(int $id, ?User $user = null): Product
    {
        /** @var Product $product */
        $product = $this->products->findOrFail($id);
        $product->load(['images', 'colors', 'sizes', 'store', 'category']);

        if ($user) {
            $product->setAttribute(
                'is_favorite',
                $this->favorites->findForUserProduct($user, $product->id) !== null
            );
        }

        return $product;
    }

    public function reviews(int $productId, int $perPage = 15): LengthAwarePaginator
    {
        return $this->reviews->forProduct($productId, $perPage);
    }

    public function addReview(User $user, array $data)
    {
        $review = $this->reviews->create([
            'user_id' => $user->id,
            'product_id' => $data['product_id'],
            'rating' => $data['rating'],
            'body' => $data['body'] ?? null,
        ]);

        $this->recalculateProductRating((int) $data['product_id']);

        return $review->load('user');
    }

    private function recalculateProductRating(int $productId): void
    {
        /** @var Product $product */
        $product = $this->products->findOrFail($productId);
        $avg = $product->reviews()->avg('rating') ?? 0;
        $count = $product->reviews()->count();
        $this->products->update($product, [
            'rating_avg' => round((float) $avg, 2),
            'reviews_count' => $count,
        ]);
    }
}
PHP);

w("$base/app/Services/CatalogService.php", <<<'PHP'
<?php

namespace App\Services;

use App\Contracts\Repositories\CategoryRepositoryInterface;
use App\Contracts\Repositories\ProductRepositoryInterface;
use App\Models\Category;
use Illuminate\Contracts\Pagination\LengthAwarePaginator;
use Illuminate\Database\Eloquent\Collection;

class CatalogService
{
    public function __construct(
        private readonly CategoryRepositoryInterface $categories,
        private readonly ProductRepositoryInterface $products,
    ) {
    }

    public function categories(): Collection
    {
        return $this->categories->activeRoots();
    }

    public function category(int $id): Category
    {
        /** @var Category $category */
        $category = $this->categories->findOrFail($id);

        return $category->load('children');
    }

    public function categoryProducts(int $categoryId, int $perPage = 15): LengthAwarePaginator
    {
        return $this->products->forCategory($categoryId, $perPage);
    }
}
PHP);

w("$base/app/Services/StoreService.php", <<<'PHP'
<?php

namespace App\Services;

use App\Contracts\Repositories\ProductRepositoryInterface;
use App\Contracts\Repositories\StoreRepositoryInterface;
use App\Models\Store;
use Illuminate\Contracts\Pagination\LengthAwarePaginator;

class StoreService
{
    public function __construct(
        private readonly StoreRepositoryInterface $stores,
        private readonly ProductRepositoryInterface $products,
    ) {
    }

    public function show(int $id): Store
    {
        /** @var Store $store */
        $store = $this->stores->findOrFail($id);
        $store->setAttribute('product_count', $store->products()->where('is_active', true)->count());

        return $store;
    }

    public function products(int $storeId, int $perPage = 15): LengthAwarePaginator
    {
        return $this->products->forStore($storeId, $perPage);
    }
}
PHP);

w("$base/app/Services/FavoriteService.php", <<<'PHP'
<?php

namespace App\Services;

use App\Contracts\Repositories\FavoriteRepositoryInterface;
use App\Contracts\Repositories\ProductRepositoryInterface;
use App\Exceptions\DomainException;
use App\Models\User;
use Illuminate\Contracts\Pagination\LengthAwarePaginator;
use Illuminate\Support\Facades\DB;

class FavoriteService
{
    public function __construct(
        private readonly FavoriteRepositoryInterface $favorites,
        private readonly ProductRepositoryInterface $products,
    ) {
    }

    public function list(User $user, int $perPage = 15): LengthAwarePaginator
    {
        return $this->favorites->forUser($user, $perPage);
    }

    public function add(User $user, int $productId)
    {
        $this->products->findOrFail($productId);

        if ($this->favorites->findForUserProduct($user, $productId)) {
            throw new DomainException('Product is already in favorites.', 422, 'already_favorited');
        }

        return DB::transaction(function () use ($user, $productId) {
            $favorite = $this->favorites->create([
                'user_id' => $user->id,
                'product_id' => $productId,
            ]);

            $user->member?->increment('favorites_count');

            return $favorite->load(['product.images', 'product.store']);
        });
    }

    public function remove(User $user, int $productId): void
    {
        $favorite = $this->favorites->findForUserProduct($user, $productId);

        if (! $favorite) {
            throw new DomainException('Favorite not found.', 404, 'favorite_not_found');
        }

        DB::transaction(function () use ($user, $favorite) {
            $this->favorites->delete($favorite);
            if ($user->member && $user->member->favorites_count > 0) {
                $user->member->decrement('favorites_count');
            }
        });
    }

    public function clear(User $user): void
    {
        DB::transaction(function () use ($user) {
            $this->favorites->clearForUser($user);
            $user->member?->update(['favorites_count' => 0]);
        });
    }
}
PHP);

w("$base/app/Services/CartService.php", <<<'PHP'
<?php

namespace App\Services;

use App\Contracts\Repositories\CartRepositoryInterface;
use App\Contracts\Repositories\ProductRepositoryInterface;
use App\Exceptions\DomainException;
use App\Models\Cart;
use App\Models\CartItem;
use App\Models\Product;
use App\Models\User;
use Illuminate\Support\Facades\DB;

class CartService
{
    public function __construct(
        private readonly CartRepositoryInterface $carts,
        private readonly ProductRepositoryInterface $products,
    ) {
    }

    public function get(User $user): Cart
    {
        $cart = $this->carts->getOrCreateForUser($user);

        return $cart->load(['items.product.images']);
    }

    public function addItem(User $user, array $data): Cart
    {
        /** @var Product $product */
        $product = $this->products->findOrFail($data['product_id']);
        $product->load('images');

        if ($product->stock < ($data['quantity'] ?? 1)) {
            throw new DomainException('Insufficient stock.', 422, 'insufficient_stock');
        }

        return DB::transaction(function () use ($user, $product, $data) {
            $cart = $this->carts->getOrCreateForUser($user);

            $existing = $cart->items()
                ->where('product_id', $product->id)
                ->where('color_name', $data['color_name'] ?? null)
                ->where('size', $data['size'] ?? null)
                ->first();

            if ($existing) {
                $existing->update([
                    'quantity' => $existing->quantity + ($data['quantity'] ?? 1),
                    'unit_price' => $product->discount_price ?? $product->price,
                ]);
            } else {
                $cart->items()->create([
                    'product_id' => $product->id,
                    'name' => $product->name,
                    'unit_price' => $product->discount_price ?? $product->price,
                    'quantity' => $data['quantity'] ?? 1,
                    'image_path' => $product->primaryImage()?->path,
                    'brand' => $product->brand,
                    'color_name' => $data['color_name'] ?? null,
                    'size' => $data['size'] ?? null,
                    'is_selected' => true,
                ]);
            }

            return $cart->fresh()->load(['items.product.images']);
        });
    }

    public function updateItem(User $user, int $itemId, array $data): Cart
    {
        $cart = $this->carts->getOrCreateForUser($user);
        $item = $this->carts->findItem($cart, $itemId);

        if (! $item) {
            throw new DomainException('Cart item not found.', 404, 'cart_item_not_found');
        }

        $payload = [];
        if (array_key_exists('quantity', $data)) {
            $payload['quantity'] = $data['quantity'];
        }
        if (array_key_exists('is_selected', $data)) {
            $payload['is_selected'] = $data['is_selected'];
        }

        $item->update($payload);

        return $cart->fresh()->load(['items.product.images']);
    }

    public function removeItem(User $user, int $itemId): Cart
    {
        $cart = $this->carts->getOrCreateForUser($user);
        $item = $this->carts->findItem($cart, $itemId);

        if (! $item) {
            throw new DomainException('Cart item not found.', 404, 'cart_item_not_found');
        }

        $item->delete();

        return $cart->fresh()->load(['items.product.images']);
    }

    public function selectAll(User $user, bool $selected = true): Cart
    {
        $cart = $this->carts->getOrCreateForUser($user);
        $cart->items()->update(['is_selected' => $selected]);

        return $cart->fresh()->load(['items.product.images']);
    }
}
PHP);

w("$base/app/Services/CheckoutService.php", <<<'PHP'
<?php

namespace App\Services;

use App\Contracts\Repositories\AddressRepositoryInterface;
use App\Contracts\Repositories\CartRepositoryInterface;
use App\Contracts\Repositories\OrderRepositoryInterface;
use App\Contracts\Repositories\PaymentMethodRepositoryInterface;
use App\Contracts\Repositories\ProductRepositoryInterface;
use App\Enums\OrderStatus;
use App\Exceptions\DomainException;
use App\Models\Order;
use App\Models\User;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Str;

class CheckoutService
{
    public function __construct(
        private readonly CartRepositoryInterface $carts,
        private readonly AddressRepositoryInterface $addresses,
        private readonly PaymentMethodRepositoryInterface $paymentMethods,
        private readonly OrderRepositoryInterface $orders,
        private readonly ProductRepositoryInterface $products,
    ) {
    }

    public function checkout(User $user, array $data): Order
    {
        $cart = $this->carts->getOrCreateForUser($user)->load('items');
        $selected = $cart->items->where('is_selected', true);

        if ($selected->isEmpty()) {
            throw new DomainException('No selected cart items to checkout.', 422, 'empty_checkout');
        }

        $address = $this->addresses->findOrFail($data['address_id']);
        if ($address->user_id !== $user->id) {
            throw new DomainException('Invalid address.', 403, 'invalid_address');
        }

        $payment = $this->paymentMethods->findOrFail($data['payment_method_id']);
        if ($payment->user_id !== $user->id) {
            throw new DomainException('Invalid payment method.', 403, 'invalid_payment_method');
        }

        return DB::transaction(function () use ($user, $cart, $selected, $address, $payment, $data) {
            foreach ($selected as $item) {
                /** @var \App\Models\Product $product */
                $product = $this->products->findOrFail($item->product_id);
                $product = $this->products->query()->lockForUpdate()->findOrFail($product->id);
                if ($product->stock < $item->quantity) {
                    throw new DomainException("Insufficient stock for {$product->name}.", 422, 'insufficient_stock');
                }
            }

            $subtotal = $selected->sum(fn ($i) => (float) $i->unit_price * $i->quantity);
            $shipping = (float) ($data['shipping_fee'] ?? 0);
            $discount = (float) ($data['discount'] ?? 0);
            $total = max(0, $subtotal + $shipping - $discount);

            /** @var Order $order */
            $order = $this->orders->create([
                'user_id' => $user->id,
                'order_number' => 'ORD-'.Str::upper(Str::random(10)),
                'status' => OrderStatus::Paid,
                'subtotal' => $subtotal,
                'shipping_fee' => $shipping,
                'discount' => $discount,
                'total' => $total,
                'currency' => $cart->currency,
                'address_id' => $address->id,
                'payment_method_id' => $payment->id,
                'placed_at' => now(),
            ]);

            foreach ($selected as $item) {
                $order->items()->create([
                    'product_id' => $item->product_id,
                    'name' => $item->name,
                    'unit_price' => $item->unit_price,
                    'quantity' => $item->quantity,
                    'image_path' => $item->image_path,
                    'variant_label' => trim(implode(' / ', array_filter([$item->color_name, $item->size]))),
                ]);

                $product = $this->products->findOrFail($item->product_id);
                $this->products->update($product, [
                    'stock' => max(0, $product->stock - $item->quantity),
                ]);
            }

            $order->trackingEvents()->createMany([
                [
                    'title' => 'Order Placed',
                    'description' => 'We have received your order.',
                    'occurred_at' => now(),
                    'is_completed' => true,
                    'sort_order' => 1,
                ],
                [
                    'title' => 'Payment Confirmed',
                    'description' => 'Payment has been confirmed.',
                    'occurred_at' => now(),
                    'is_completed' => true,
                    'sort_order' => 2,
                ],
                [
                    'title' => 'Processing',
                    'description' => 'Seller is preparing your package.',
                    'occurred_at' => now()->addHour(),
                    'is_completed' => false,
                    'sort_order' => 3,
                ],
            ]);

            $cart->items()->whereIn('id', $selected->pluck('id'))->delete();
            $user->member?->increment('orders_count');

            return $order->load(['items', 'address', 'paymentMethod', 'trackingEvents']);
        });
    }
}
PHP);

echo "First services batch done\n";
