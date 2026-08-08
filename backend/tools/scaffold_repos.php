<?php

/**
 * Scaffold repositories, contracts, services, resources, requests, controllers, policies.
 */
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

// ========== Contracts ==========
$contracts = [
'UserRepositoryInterface' => <<<'PHP'
<?php

namespace App\Contracts\Repositories;

use App\Models\User;

interface UserRepositoryInterface extends BaseRepositoryInterface
{
    public function findByEmail(string $email): ?User;

    public function findByPhone(string $phone): ?User;

    public function findByIdentifier(string $identifier): ?User;
}
PHP,
'ProductRepositoryInterface' => <<<'PHP'
<?php

namespace App\Contracts\Repositories;

use Illuminate\Contracts\Pagination\LengthAwarePaginator;
use Illuminate\Database\Eloquent\Collection;

interface ProductRepositoryInterface extends BaseRepositoryInterface
{
    public function search(array $filters, int $perPage = 15): LengthAwarePaginator;

    public function newArrivals(int $limit = 10): Collection;

    public function forStore(int $storeId, int $perPage = 15): LengthAwarePaginator;

    public function forCategory(int $categoryId, int $perPage = 15): LengthAwarePaginator;
}
PHP,
'CategoryRepositoryInterface' => <<<'PHP'
<?php

namespace App\Contracts\Repositories;

use Illuminate\Database\Eloquent\Collection;

interface CategoryRepositoryInterface extends BaseRepositoryInterface
{
    public function activeRoots(): Collection;
}
PHP,
'StoreRepositoryInterface' => <<<'PHP'
<?php

namespace App\Contracts\Repositories;

interface StoreRepositoryInterface extends BaseRepositoryInterface
{
}
PHP,
'PromotionRepositoryInterface' => <<<'PHP'
<?php

namespace App\Contracts\Repositories;

use Illuminate\Database\Eloquent\Collection;

interface PromotionRepositoryInterface extends BaseRepositoryInterface
{
    public function activePromotions(): Collection;
}
PHP,
'FavoriteRepositoryInterface' => <<<'PHP'
<?php

namespace App\Contracts\Repositories;

use App\Models\Favorite;
use App\Models\User;
use Illuminate\Contracts\Pagination\LengthAwarePaginator;

interface FavoriteRepositoryInterface extends BaseRepositoryInterface
{
    public function forUser(User $user, int $perPage = 15): LengthAwarePaginator;

    public function findForUserProduct(User $user, int $productId): ?Favorite;

    public function clearForUser(User $user): int;
}
PHP,
'CartRepositoryInterface' => <<<'PHP'
<?php

namespace App\Contracts\Repositories;

use App\Models\Cart;
use App\Models\CartItem;
use App\Models\User;

interface CartRepositoryInterface extends BaseRepositoryInterface
{
    public function getOrCreateForUser(User $user): Cart;

    public function findItem(Cart $cart, int $itemId): ?CartItem;
}
PHP,
'AddressRepositoryInterface' => <<<'PHP'
<?php

namespace App\Contracts\Repositories;

use App\Models\User;
use Illuminate\Database\Eloquent\Collection;

interface AddressRepositoryInterface extends BaseRepositoryInterface
{
    public function forUser(User $user): Collection;

    public function clearDefault(User $user): void;
}
PHP,
'PaymentMethodRepositoryInterface' => <<<'PHP'
<?php

namespace App\Contracts\Repositories;

use App\Models\User;
use Illuminate\Database\Eloquent\Collection;

interface PaymentMethodRepositoryInterface extends BaseRepositoryInterface
{
    public function forUser(User $user): Collection;

    public function clearDefault(User $user): void;
}
PHP,
'OrderRepositoryInterface' => <<<'PHP'
<?php

namespace App\Contracts\Repositories;

use App\Models\User;
use Illuminate\Contracts\Pagination\LengthAwarePaginator;

interface OrderRepositoryInterface extends BaseRepositoryInterface
{
    public function activeForUser(User $user, int $perPage = 15): LengthAwarePaginator;

    public function historyForUser(User $user, int $perPage = 15): LengthAwarePaginator;
}
PHP,
'ConversationRepositoryInterface' => <<<'PHP'
<?php

namespace App\Contracts\Repositories;

use App\Models\Conversation;
use App\Models\User;
use Illuminate\Contracts\Pagination\LengthAwarePaginator;

interface ConversationRepositoryInterface extends BaseRepositoryInterface
{
    public function forUser(User $user, int $perPage = 15): LengthAwarePaginator;

    public function findBetweenUserAndStore(User $user, int $storeId): ?Conversation;
}
PHP,
'NotificationRepositoryInterface' => <<<'PHP'
<?php

namespace App\Contracts\Repositories;

use App\Models\User;
use Illuminate\Contracts\Pagination\LengthAwarePaginator;

interface NotificationRepositoryInterface extends BaseRepositoryInterface
{
    public function forUser(User $user, int $perPage = 15): LengthAwarePaginator;

    public function markAllRead(User $user): int;
}
PHP,
'RfidRepositoryInterface' => <<<'PHP'
<?php

namespace App\Contracts\Repositories;

use App\Models\RfidMember;

interface RfidRepositoryInterface extends BaseRepositoryInterface
{
    public function findActiveMember(string $memberId): ?RfidMember;
}
PHP,
'ReviewRepositoryInterface' => <<<'PHP'
<?php

namespace App\Contracts\Repositories;

use Illuminate\Contracts\Pagination\LengthAwarePaginator;

interface ReviewRepositoryInterface extends BaseRepositoryInterface
{
    public function forProduct(int $productId, int $perPage = 15): LengthAwarePaginator;
}
PHP,
'SettingsRepositoryInterface' => <<<'PHP'
<?php

namespace App\Contracts\Repositories;

use App\Models\User;
use App\Models\UserSetting;

interface SettingsRepositoryInterface extends BaseRepositoryInterface
{
    public function forUser(User $user): UserSetting;
}
PHP,
];

foreach ($contracts as $name => $body) {
    w("$base/app/Contracts/Repositories/{$name}.php", $body);
}

// ========== Repository implementations ==========
w("$base/app/Repositories/UserRepository.php", <<<'PHP'
<?php

namespace App\Repositories;

use App\Contracts\Repositories\UserRepositoryInterface;
use App\Models\User;

class UserRepository extends BaseRepository implements UserRepositoryInterface
{
    public function __construct(User $model)
    {
        parent::__construct($model);
    }

    public function findByEmail(string $email): ?User
    {
        return $this->query()->where('email', $email)->first();
    }

    public function findByPhone(string $phone): ?User
    {
        return $this->query()->where('phone', $phone)->first();
    }

    public function findByIdentifier(string $identifier): ?User
    {
        return $this->query()
            ->where(function ($q) use ($identifier) {
                $q->where('email', $identifier)->orWhere('phone', $identifier);
            })
            ->first();
    }
}
PHP);

w("$base/app/Repositories/ProductRepository.php", <<<'PHP'
<?php

namespace App\Repositories;

use App\Contracts\Repositories\ProductRepositoryInterface;
use App\Models\Product;
use Illuminate\Contracts\Pagination\LengthAwarePaginator;
use Illuminate\Database\Eloquent\Builder;
use Illuminate\Database\Eloquent\Collection;

class ProductRepository extends BaseRepository implements ProductRepositoryInterface
{
    public function __construct(Product $model)
    {
        parent::__construct($model);
    }

    public function search(array $filters, int $perPage = 15): LengthAwarePaginator
    {
        $query = $this->query()
            ->with(['images', 'colors', 'sizes', 'store'])
            ->where('is_active', true);

        if (! empty($filters['q'])) {
            $q = $filters['q'];
            $query->where(function (Builder $builder) use ($q) {
                $builder->where('name', 'like', "%{$q}%")
                    ->orWhere('brand', 'like', "%{$q}%")
                    ->orWhere('description', 'like', "%{$q}%");
            });
        }

        if (! empty($filters['category_id'])) {
            $query->where('category_id', $filters['category_id']);
        }

        if (! empty($filters['store_id'])) {
            $query->where('store_id', $filters['store_id']);
        }

        if (isset($filters['min_price'])) {
            $query->where('price', '>=', $filters['min_price']);
        }

        if (isset($filters['max_price'])) {
            $query->where('price', '<=', $filters['max_price']);
        }

        if (! empty($filters['color_ids']) && is_array($filters['color_ids'])) {
            $query->whereHas('colors', fn (Builder $b) => $b->whereIn('product_colors.id', $filters['color_ids']));
        }

        if (! empty($filters['locations']) && is_array($filters['locations'])) {
            $query->whereHas('store', fn (Builder $b) => $b->whereIn('location', $filters['locations']));
        }

        $sort = $filters['sort'] ?? 'all';
        match ($sort) {
            'price_asc' => $query->orderBy('price'),
            'price_desc' => $query->orderByDesc('price'),
            'rating' => $query->orderByDesc('rating_avg'),
            'newest' => $query->orderByDesc('created_at'),
            default => $query->orderByDesc('id'),
        };

        return $query->paginate($perPage);
    }

    public function newArrivals(int $limit = 10): Collection
    {
        return $this->query()
            ->with(['images', 'colors', 'store'])
            ->where('is_active', true)
            ->latest()
            ->limit($limit)
            ->get();
    }

    public function forStore(int $storeId, int $perPage = 15): LengthAwarePaginator
    {
        return $this->query()
            ->with(['images', 'colors', 'sizes'])
            ->where('store_id', $storeId)
            ->where('is_active', true)
            ->latest()
            ->paginate($perPage);
    }

    public function forCategory(int $categoryId, int $perPage = 15): LengthAwarePaginator
    {
        return $this->query()
            ->with(['images', 'colors', 'store'])
            ->where('category_id', $categoryId)
            ->where('is_active', true)
            ->latest()
            ->paginate($perPage);
    }
}
PHP);

w("$base/app/Repositories/CategoryRepository.php", <<<'PHP'
<?php

namespace App\Repositories;

use App\Contracts\Repositories\CategoryRepositoryInterface;
use App\Models\Category;
use Illuminate\Database\Eloquent\Collection;

class CategoryRepository extends BaseRepository implements CategoryRepositoryInterface
{
    public function __construct(Category $model)
    {
        parent::__construct($model);
    }

    public function activeRoots(): Collection
    {
        return $this->query()
            ->with('children')
            ->whereNull('parent_id')
            ->where('is_active', true)
            ->orderBy('sort_order')
            ->get();
    }
}
PHP);

w("$base/app/Repositories/StoreRepository.php", <<<'PHP'
<?php

namespace App\Repositories;

use App\Contracts\Repositories\StoreRepositoryInterface;
use App\Models\Store;

class StoreRepository extends BaseRepository implements StoreRepositoryInterface
{
    public function __construct(Store $model)
    {
        parent::__construct($model);
    }
}
PHP);

w("$base/app/Repositories/PromotionRepository.php", <<<'PHP'
<?php

namespace App\Repositories;

use App\Contracts\Repositories\PromotionRepositoryInterface;
use App\Models\Promotion;
use Illuminate\Database\Eloquent\Collection;

class PromotionRepository extends BaseRepository implements PromotionRepositoryInterface
{
    public function __construct(Promotion $model)
    {
        parent::__construct($model);
    }

    public function activePromotions(): Collection
    {
        return $this->query()->active()->orderBy('sort_order')->get();
    }
}
PHP);

w("$base/app/Repositories/FavoriteRepository.php", <<<'PHP'
<?php

namespace App\Repositories;

use App\Contracts\Repositories\FavoriteRepositoryInterface;
use App\Models\Favorite;
use App\Models\User;
use Illuminate\Contracts\Pagination\LengthAwarePaginator;

class FavoriteRepository extends BaseRepository implements FavoriteRepositoryInterface
{
    public function __construct(Favorite $model)
    {
        parent::__construct($model);
    }

    public function forUser(User $user, int $perPage = 15): LengthAwarePaginator
    {
        return $this->query()
            ->with(['product.images', 'product.store', 'product.colors'])
            ->where('user_id', $user->id)
            ->latest()
            ->paginate($perPage);
    }

    public function findForUserProduct(User $user, int $productId): ?Favorite
    {
        return $this->query()
            ->where('user_id', $user->id)
            ->where('product_id', $productId)
            ->first();
    }

    public function clearForUser(User $user): int
    {
        return $this->query()->where('user_id', $user->id)->delete();
    }
}
PHP);

w("$base/app/Repositories/CartRepository.php", <<<'PHP'
<?php

namespace App\Repositories;

use App\Contracts\Repositories\CartRepositoryInterface;
use App\Models\Cart;
use App\Models\CartItem;
use App\Models\User;

class CartRepository extends BaseRepository implements CartRepositoryInterface
{
    public function __construct(Cart $model)
    {
        parent::__construct($model);
    }

    public function getOrCreateForUser(User $user): Cart
    {
        return $this->query()->firstOrCreate(
            ['user_id' => $user->id],
            ['currency' => $user->settings?->currency_code ?? 'USD']
        );
    }

    public function findItem(Cart $cart, int $itemId): ?CartItem
    {
        return $cart->items()->whereKey($itemId)->first();
    }
}
PHP);

w("$base/app/Repositories/AddressRepository.php", <<<'PHP'
<?php

namespace App\Repositories;

use App\Contracts\Repositories\AddressRepositoryInterface;
use App\Models\Address;
use App\Models\User;
use Illuminate\Database\Eloquent\Collection;

class AddressRepository extends BaseRepository implements AddressRepositoryInterface
{
    public function __construct(Address $model)
    {
        parent::__construct($model);
    }

    public function forUser(User $user): Collection
    {
        return $this->query()->where('user_id', $user->id)->latest()->get();
    }

    public function clearDefault(User $user): void
    {
        $this->query()->where('user_id', $user->id)->update(['is_default' => false]);
    }
}
PHP);

w("$base/app/Repositories/PaymentMethodRepository.php", <<<'PHP'
<?php

namespace App\Repositories;

use App\Contracts\Repositories\PaymentMethodRepositoryInterface;
use App\Models\PaymentMethod;
use App\Models\User;
use Illuminate\Database\Eloquent\Collection;

class PaymentMethodRepository extends BaseRepository implements PaymentMethodRepositoryInterface
{
    public function __construct(PaymentMethod $model)
    {
        parent::__construct($model);
    }

    public function forUser(User $user): Collection
    {
        return $this->query()->where('user_id', $user->id)->latest()->get();
    }

    public function clearDefault(User $user): void
    {
        $this->query()->where('user_id', $user->id)->update(['is_default' => false]);
    }
}
PHP);

w("$base/app/Repositories/OrderRepository.php", <<<'PHP'
<?php

namespace App\Repositories;

use App\Contracts\Repositories\OrderRepositoryInterface;
use App\Enums\OrderStatus;
use App\Models\Order;
use App\Models\User;
use Illuminate\Contracts\Pagination\LengthAwarePaginator;

class OrderRepository extends BaseRepository implements OrderRepositoryInterface
{
    public function __construct(Order $model)
    {
        parent::__construct($model);
    }

    public function activeForUser(User $user, int $perPage = 15): LengthAwarePaginator
    {
        return $this->query()
            ->with(['items', 'trackingEvents'])
            ->where('user_id', $user->id)
            ->whereIn('status', [
                OrderStatus::Pending->value,
                OrderStatus::Paid->value,
                OrderStatus::Processing->value,
                OrderStatus::Shipped->value,
            ])
            ->latest('placed_at')
            ->paginate($perPage);
    }

    public function historyForUser(User $user, int $perPage = 15): LengthAwarePaginator
    {
        return $this->query()
            ->with(['items'])
            ->where('user_id', $user->id)
            ->whereIn('status', [
                OrderStatus::Delivered->value,
                OrderStatus::Cancelled->value,
                OrderStatus::Refunded->value,
            ])
            ->latest('placed_at')
            ->paginate($perPage);
    }
}
PHP);

w("$base/app/Repositories/ConversationRepository.php", <<<'PHP'
<?php

namespace App\Repositories;

use App\Contracts\Repositories\ConversationRepositoryInterface;
use App\Models\Conversation;
use App\Models\User;
use Illuminate\Contracts\Pagination\LengthAwarePaginator;

class ConversationRepository extends BaseRepository implements ConversationRepositoryInterface
{
    public function __construct(Conversation $model)
    {
        parent::__construct($model);
    }

    public function forUser(User $user, int $perPage = 15): LengthAwarePaginator
    {
        return $this->query()
            ->with(['store', 'messages' => fn ($q) => $q->latest()->limit(1)])
            ->whereHas('participants', fn ($q) => $q->where('users.id', $user->id))
            ->orderByDesc('last_message_at')
            ->paginate($perPage);
    }

    public function findBetweenUserAndStore(User $user, int $storeId): ?Conversation
    {
        return $this->query()
            ->where('store_id', $storeId)
            ->whereHas('participants', fn ($q) => $q->where('users.id', $user->id))
            ->first();
    }
}
PHP);

w("$base/app/Repositories/NotificationRepository.php", <<<'PHP'
<?php

namespace App\Repositories;

use App\Contracts\Repositories\NotificationRepositoryInterface;
use App\Models\AppNotification;
use App\Models\User;
use Illuminate\Contracts\Pagination\LengthAwarePaginator;

class NotificationRepository extends BaseRepository implements NotificationRepositoryInterface
{
    public function __construct(AppNotification $model)
    {
        parent::__construct($model);
    }

    public function forUser(User $user, int $perPage = 15): LengthAwarePaginator
    {
        return $this->query()
            ->where('user_id', $user->id)
            ->latest()
            ->paginate($perPage);
    }

    public function markAllRead(User $user): int
    {
        return $this->query()
            ->where('user_id', $user->id)
            ->where('is_read', false)
            ->update(['is_read' => true]);
    }
}
PHP);

w("$base/app/Repositories/RfidRepository.php", <<<'PHP'
<?php

namespace App\Repositories;

use App\Contracts\Repositories\RfidRepositoryInterface;
use App\Models\RfidMember;
use App\Models\RfidVerification;

class RfidRepository extends BaseRepository implements RfidRepositoryInterface
{
    public function __construct(RfidMember $model)
    {
        parent::__construct($model);
    }

    public function findActiveMember(string $memberId): ?RfidMember
    {
        return $this->query()
            ->where('is_active', true)
            ->where(function ($q) use ($memberId) {
                $q->where('member_code', $memberId)
                    ->orWhere('rfid_uid', $memberId);
            })
            ->first();
    }

    public function createVerification(array $attributes): RfidVerification
    {
        return RfidVerification::query()->create($attributes);
    }
}
PHP);

w("$base/app/Repositories/ReviewRepository.php", <<<'PHP'
<?php

namespace App\Repositories;

use App\Contracts\Repositories\ReviewRepositoryInterface;
use App\Models\Review;
use Illuminate\Contracts\Pagination\LengthAwarePaginator;

class ReviewRepository extends BaseRepository implements ReviewRepositoryInterface
{
    public function __construct(Review $model)
    {
        parent::__construct($model);
    }

    public function forProduct(int $productId, int $perPage = 15): LengthAwarePaginator
    {
        return $this->query()
            ->with('user')
            ->where('product_id', $productId)
            ->latest()
            ->paginate($perPage);
    }
}
PHP);

w("$base/app/Repositories/SettingsRepository.php", <<<'PHP'
<?php

namespace App\Repositories;

use App\Contracts\Repositories\SettingsRepositoryInterface;
use App\Models\User;
use App\Models\UserSetting;

class SettingsRepository extends BaseRepository implements SettingsRepositoryInterface
{
    public function __construct(UserSetting $model)
    {
        parent::__construct($model);
    }

    public function forUser(User $user): UserSetting
    {
        return $this->query()->firstOrCreate(
            ['user_id' => $user->id],
            [
                'language_code' => 'en',
                'language_label' => 'English',
                'currency_code' => 'USD',
            ]
        );
    }
}
PHP);

echo "Repositories done\n";
