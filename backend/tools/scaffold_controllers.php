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

w("$base/app/Http/Controllers/Controller.php", <<<'PHP'
<?php

namespace App\Http\Controllers;

abstract class Controller
{
    //
}
PHP);

w("$base/app/Http/Controllers/Api/Auth/AuthController.php", <<<'PHP'
<?php

namespace App\Http\Controllers\Api\Auth;

use App\Http\Controllers\Controller;
use App\Http\Requests\Auth\ForgotPasswordRequest;
use App\Http\Requests\Auth\LoginRequest;
use App\Http\Requests\Auth\RegisterRequest;
use App\Http\Requests\Auth\ResetPasswordRequest;
use App\Http\Resources\AuthTokenResource;
use App\Services\AuthService;
use App\Support\ApiResponse;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class AuthController extends Controller
{
    public function __construct(private readonly AuthService $auth)
    {
    }

    public function register(RegisterRequest $request): JsonResponse
    {
        $result = $this->auth->register($request->validated());

        return ApiResponse::resource(new AuthTokenResource($result), 'Registered successfully', 201);
    }

    public function login(LoginRequest $request): JsonResponse
    {
        $result = $this->auth->login(
            $request->validated('identifier'),
            $request->validated('password'),
        );

        return ApiResponse::resource(new AuthTokenResource($result), 'Logged in successfully');
    }

    public function logout(Request $request): JsonResponse
    {
        $this->auth->logout($request->user());

        return ApiResponse::success(null, 'Logged out successfully');
    }

    public function forgotPassword(ForgotPasswordRequest $request): JsonResponse
    {
        $message = $this->auth->forgotPassword($request->validated('email'));

        return ApiResponse::success(null, $message);
    }

    public function resetPassword(ResetPasswordRequest $request): JsonResponse
    {
        $message = $this->auth->resetPassword($request->validated());

        return ApiResponse::success(null, $message);
    }
}
PHP);

w("$base/app/Http/Controllers/Api/Profile/ProfileController.php", <<<'PHP'
<?php

namespace App\Http\Controllers\Api\Profile;

use App\Http\Controllers\Controller;
use App\Http\Requests\Profile\ChangePasswordRequest;
use App\Http\Requests\Profile\UpdateProfileRequest;
use App\Http\Resources\UserResource;
use App\Services\ProfileService;
use App\Support\ApiResponse;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class ProfileController extends Controller
{
    public function __construct(private readonly ProfileService $profiles)
    {
    }

    public function me(Request $request): JsonResponse
    {
        return ApiResponse::resource(new UserResource($this->profiles->me($request->user())));
    }

    public function update(UpdateProfileRequest $request): JsonResponse
    {
        $user = $this->profiles->updateProfile($request->user(), $request->validated());

        return ApiResponse::resource(new UserResource($user), 'Profile updated');
    }

    public function changePassword(ChangePasswordRequest $request): JsonResponse
    {
        $this->profiles->changePassword(
            $request->user(),
            $request->validated('current_password'),
            $request->validated('password'),
        );

        return ApiResponse::success(null, 'Password changed successfully');
    }
}
PHP);

w("$base/app/Http/Controllers/Api/Profile/SettingsController.php", <<<'PHP'
<?php

namespace App\Http\Controllers\Api\Profile;

use App\Http\Controllers\Controller;
use App\Http\Requests\Settings\UpdateSettingsRequest;
use App\Http\Resources\SettingsResource;
use App\Services\SettingsService;
use App\Support\ApiResponse;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class SettingsController extends Controller
{
    public function __construct(private readonly SettingsService $settings)
    {
    }

    public function show(Request $request): JsonResponse
    {
        return ApiResponse::resource(new SettingsResource($this->settings->get($request->user())));
    }

    public function update(UpdateSettingsRequest $request): JsonResponse
    {
        $setting = $this->settings->update($request->user(), $request->validated());

        return ApiResponse::resource(new SettingsResource($setting), 'Settings updated');
    }

    public function languages(): JsonResponse
    {
        return ApiResponse::success($this->settings->languages());
    }
}
PHP);

w("$base/app/Http/Controllers/Api/Home/HomeController.php", <<<'PHP'
<?php

namespace App\Http\Controllers\Api\Home;

use App\Http\Controllers\Controller;
use App\Http\Resources\HomeFeedResource;
use App\Services\HomeFeedService;
use App\Support\ApiResponse;
use Illuminate\Http\JsonResponse;

class HomeController extends Controller
{
    public function __construct(private readonly HomeFeedService $home)
    {
    }

    public function __invoke(): JsonResponse
    {
        return ApiResponse::resource(new HomeFeedResource($this->home->feed()));
    }
}
PHP);

w("$base/app/Http/Controllers/Api/Catalog/CategoryController.php", <<<'PHP'
<?php

namespace App\Http\Controllers\Api\Catalog;

use App\Http\Controllers\Controller;
use App\Http\Resources\CategoryResource;
use App\Http\Resources\ProductResource;
use App\Services\CatalogService;
use App\Support\ApiResponse;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class CategoryController extends Controller
{
    public function __construct(private readonly CatalogService $catalog)
    {
    }

    public function index(): JsonResponse
    {
        return ApiResponse::resource(CategoryResource::collection($this->catalog->categories()));
    }

    public function show(int $category): JsonResponse
    {
        return ApiResponse::resource(new CategoryResource($this->catalog->category($category)));
    }

    public function products(Request $request, int $category): JsonResponse
    {
        $paginator = $this->catalog->categoryProducts($category, (int) $request->integer('per_page', 15));

        return ApiResponse::resource(ProductResource::collection($paginator));
    }
}
PHP);

w("$base/app/Http/Controllers/Api/Product/ProductController.php", <<<'PHP'
<?php

namespace App\Http\Controllers\Api\Product;

use App\Http\Controllers\Controller;
use App\Http\Requests\Product\StoreReviewRequest;
use App\Http\Requests\Search\ProductSearchRequest;
use App\Http\Resources\ProductResource;
use App\Http\Resources\ReviewResource;
use App\Services\ProductService;
use App\Support\ApiResponse;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class ProductController extends Controller
{
    public function __construct(private readonly ProductService $products)
    {
    }

    public function index(ProductSearchRequest $request): JsonResponse
    {
        $paginator = $this->products->search(
            $request->validated(),
            (int) $request->integer('per_page', 15),
        );

        return ApiResponse::resource(ProductResource::collection($paginator));
    }

    public function show(Request $request, int $product): JsonResponse
    {
        return ApiResponse::resource(
            new ProductResource($this->products->show($product, $request->user('sanctum')))
        );
    }

    public function reviews(Request $request, int $product): JsonResponse
    {
        $paginator = $this->products->reviews($product, (int) $request->integer('per_page', 15));

        return ApiResponse::resource(ReviewResource::collection($paginator));
    }

    public function storeReview(StoreReviewRequest $request): JsonResponse
    {
        $review = $this->products->addReview($request->user(), $request->validated());

        return ApiResponse::resource(new ReviewResource($review), 'Review submitted', 201);
    }
}
PHP);

w("$base/app/Http/Controllers/Api/Store/StoreController.php", <<<'PHP'
<?php

namespace App\Http\Controllers\Api\Store;

use App\Http\Controllers\Controller;
use App\Http\Resources\ProductResource;
use App\Http\Resources\StoreResource;
use App\Services\StoreService;
use App\Support\ApiResponse;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class StoreController extends Controller
{
    public function __construct(private readonly StoreService $stores)
    {
    }

    public function show(int $store): JsonResponse
    {
        return ApiResponse::resource(new StoreResource($this->stores->show($store)));
    }

    public function products(Request $request, int $store): JsonResponse
    {
        $paginator = $this->stores->products($store, (int) $request->integer('per_page', 15));

        return ApiResponse::resource(ProductResource::collection($paginator));
    }
}
PHP);

w("$base/app/Http/Controllers/Api/Favorite/FavoriteController.php", <<<'PHP'
<?php

namespace App\Http\Controllers\Api\Favorite;

use App\Http\Controllers\Controller;
use App\Http\Requests\Favorite\StoreFavoriteRequest;
use App\Http\Resources\FavoriteResource;
use App\Services\FavoriteService;
use App\Support\ApiResponse;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class FavoriteController extends Controller
{
    public function __construct(private readonly FavoriteService $favorites)
    {
    }

    public function index(Request $request): JsonResponse
    {
        $paginator = $this->favorites->list($request->user(), (int) $request->integer('per_page', 15));

        return ApiResponse::resource(FavoriteResource::collection($paginator));
    }

    public function store(StoreFavoriteRequest $request): JsonResponse
    {
        $favorite = $this->favorites->add($request->user(), (int) $request->validated('product_id'));

        return ApiResponse::resource(new FavoriteResource($favorite), 'Added to favorites', 201);
    }

    public function destroy(Request $request, int $product): JsonResponse
    {
        $this->favorites->remove($request->user(), $product);

        return ApiResponse::success(null, 'Removed from favorites');
    }

    public function clear(Request $request): JsonResponse
    {
        $this->favorites->clear($request->user());

        return ApiResponse::success(null, 'Favorites cleared');
    }
}
PHP);

w("$base/app/Http/Controllers/Api/Cart/CartController.php", <<<'PHP'
<?php

namespace App\Http\Controllers\Api\Cart;

use App\Http\Controllers\Controller;
use App\Http\Requests\Cart\SelectAllCartRequest;
use App\Http\Requests\Cart\StoreCartItemRequest;
use App\Http\Requests\Cart\UpdateCartItemRequest;
use App\Http\Resources\CartResource;
use App\Services\CartService;
use App\Support\ApiResponse;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class CartController extends Controller
{
    public function __construct(private readonly CartService $carts)
    {
    }

    public function show(Request $request): JsonResponse
    {
        return ApiResponse::resource(new CartResource($this->carts->get($request->user())));
    }

    public function storeItem(StoreCartItemRequest $request): JsonResponse
    {
        $cart = $this->carts->addItem($request->user(), $request->validated());

        return ApiResponse::resource(new CartResource($cart), 'Item added to cart', 201);
    }

    public function updateItem(UpdateCartItemRequest $request, int $cartItem): JsonResponse
    {
        $cart = $this->carts->updateItem($request->user(), $cartItem, $request->validated());

        return ApiResponse::resource(new CartResource($cart), 'Cart updated');
    }

    public function destroyItem(Request $request, int $cartItem): JsonResponse
    {
        $cart = $this->carts->removeItem($request->user(), $cartItem);

        return ApiResponse::resource(new CartResource($cart), 'Item removed');
    }

    public function selectAll(SelectAllCartRequest $request): JsonResponse
    {
        $cart = $this->carts->selectAll($request->user(), (bool) $request->validated('selected'));

        return ApiResponse::resource(new CartResource($cart), 'Selection updated');
    }
}
PHP);

w("$base/app/Http/Controllers/Api/Checkout/AddressController.php", <<<'PHP'
<?php

namespace App\Http\Controllers\Api\Checkout;

use App\Http\Controllers\Controller;
use App\Http\Requests\Checkout\StoreAddressRequest;
use App\Http\Resources\AddressResource;
use App\Services\AddressService;
use App\Support\ApiResponse;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class AddressController extends Controller
{
    public function __construct(private readonly AddressService $addresses)
    {
    }

    public function index(Request $request): JsonResponse
    {
        return ApiResponse::resource(AddressResource::collection($this->addresses->list($request->user())));
    }

    public function store(StoreAddressRequest $request): JsonResponse
    {
        $address = $this->addresses->store($request->user(), $request->validated());

        return ApiResponse::resource(new AddressResource($address), 'Address created', 201);
    }

    public function update(StoreAddressRequest $request, int $address): JsonResponse
    {
        $updated = $this->addresses->update($request->user(), $address, $request->validated());

        return ApiResponse::resource(new AddressResource($updated), 'Address updated');
    }

    public function destroy(Request $request, int $address): JsonResponse
    {
        $this->addresses->delete($request->user(), $address);

        return ApiResponse::success(null, 'Address deleted');
    }
}
PHP);

w("$base/app/Http/Controllers/Api/Checkout/PaymentMethodController.php", <<<'PHP'
<?php

namespace App\Http\Controllers\Api\Checkout;

use App\Http\Controllers\Controller;
use App\Http\Requests\Checkout\StorePaymentMethodRequest;
use App\Http\Resources\PaymentMethodResource;
use App\Services\PaymentMethodService;
use App\Support\ApiResponse;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class PaymentMethodController extends Controller
{
    public function __construct(private readonly PaymentMethodService $paymentMethods)
    {
    }

    public function index(Request $request): JsonResponse
    {
        return ApiResponse::resource(PaymentMethodResource::collection($this->paymentMethods->list($request->user())));
    }

    public function store(StorePaymentMethodRequest $request): JsonResponse
    {
        $method = $this->paymentMethods->store($request->user(), $request->validated());

        return ApiResponse::resource(new PaymentMethodResource($method), 'Payment method added', 201);
    }

    public function destroy(Request $request, int $paymentMethod): JsonResponse
    {
        $this->paymentMethods->delete($request->user(), $paymentMethod);

        return ApiResponse::success(null, 'Payment method deleted');
    }
}
PHP);

w("$base/app/Http/Controllers/Api/Checkout/CheckoutController.php", <<<'PHP'
<?php

namespace App\Http\Controllers\Api\Checkout;

use App\Http\Controllers\Controller;
use App\Http\Requests\Checkout\CheckoutRequest;
use App\Http\Resources\OrderResource;
use App\Services\CheckoutService;
use App\Support\ApiResponse;
use Illuminate\Http\JsonResponse;

class CheckoutController extends Controller
{
    public function __construct(private readonly CheckoutService $checkout)
    {
    }

    public function __invoke(CheckoutRequest $request): JsonResponse
    {
        $order = $this->checkout->checkout($request->user(), $request->validated());

        return ApiResponse::resource(new OrderResource($order), 'Order placed successfully', 201);
    }
}
PHP);

w("$base/app/Http/Controllers/Api/Order/OrderController.php", <<<'PHP'
<?php

namespace App\Http\Controllers\Api\Order;

use App\Http\Controllers\Controller;
use App\Http\Resources\OrderResource;
use App\Services\OrderService;
use App\Support\ApiResponse;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class OrderController extends Controller
{
    public function __construct(private readonly OrderService $orders)
    {
    }

    public function index(Request $request): JsonResponse
    {
        $paginator = $this->orders->active($request->user(), (int) $request->integer('per_page', 15));

        return ApiResponse::resource(OrderResource::collection($paginator));
    }

    public function history(Request $request): JsonResponse
    {
        $paginator = $this->orders->history($request->user(), (int) $request->integer('per_page', 15));

        return ApiResponse::resource(OrderResource::collection($paginator));
    }

    public function show(Request $request, int $order): JsonResponse
    {
        return ApiResponse::resource(new OrderResource($this->orders->show($request->user(), $order)));
    }

    public function track(Request $request, int $order): JsonResponse
    {
        return ApiResponse::resource(new OrderResource($this->orders->track($request->user(), $order)));
    }

    public function cancel(Request $request, int $order): JsonResponse
    {
        return ApiResponse::resource(
            new OrderResource($this->orders->cancel($request->user(), $order)),
            'Order cancelled'
        );
    }
}
PHP);

w("$base/app/Http/Controllers/Api/Messaging/ConversationController.php", <<<'PHP'
<?php

namespace App\Http\Controllers\Api\Messaging;

use App\Http\Controllers\Controller;
use App\Http\Requests\Messaging\OpenConversationRequest;
use App\Http\Requests\Messaging\StoreMessageRequest;
use App\Http\Resources\ConversationResource;
use App\Http\Resources\MessageResource;
use App\Services\ConversationService;
use App\Support\ApiResponse;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class ConversationController extends Controller
{
    public function __construct(private readonly ConversationService $conversations)
    {
    }

    public function index(Request $request): JsonResponse
    {
        $paginator = $this->conversations->list($request->user(), (int) $request->integer('per_page', 15));

        return ApiResponse::resource(ConversationResource::collection($paginator));
    }

    public function store(OpenConversationRequest $request): JsonResponse
    {
        $conversation = $this->conversations->open($request->user(), (int) $request->validated('store_id'));

        return ApiResponse::resource(new ConversationResource($conversation), 'Conversation opened', 201);
    }

    public function messages(Request $request, int $conversation): JsonResponse
    {
        $paginator = $this->conversations->messages(
            $request->user(),
            $conversation,
            (int) $request->integer('per_page', 30),
        );

        return ApiResponse::resource(MessageResource::collection($paginator));
    }

    public function send(StoreMessageRequest $request, int $conversation): JsonResponse
    {
        $message = $this->conversations->send($request->user(), $conversation, $request->validated());

        return ApiResponse::resource(new MessageResource($message), 'Message sent', 201);
    }

    public function markRead(Request $request, int $conversation): JsonResponse
    {
        $this->conversations->markRead($request->user(), $conversation);

        return ApiResponse::success(null, 'Conversation marked as read');
    }
}
PHP);

w("$base/app/Http/Controllers/Api/Notification/NotificationController.php", <<<'PHP'
<?php

namespace App\Http\Controllers\Api\Notification;

use App\Http\Controllers\Controller;
use App\Http\Resources\NotificationResource;
use App\Services\NotificationService;
use App\Support\ApiResponse;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class NotificationController extends Controller
{
    public function __construct(private readonly NotificationService $notifications)
    {
    }

    public function index(Request $request): JsonResponse
    {
        $paginator = $this->notifications->list($request->user(), (int) $request->integer('per_page', 20));

        return ApiResponse::resource(NotificationResource::collection($paginator));
    }

    public function markRead(Request $request, int $notification): JsonResponse
    {
        $item = $this->notifications->markRead($request->user(), $notification);

        return ApiResponse::resource(new NotificationResource($item), 'Notification marked as read');
    }

    public function markAllRead(Request $request): JsonResponse
    {
        $this->notifications->markAllRead($request->user());

        return ApiResponse::success(null, 'All notifications marked as read');
    }
}
PHP);

w("$base/app/Http/Controllers/Api/Rfid/RfidVerificationController.php", <<<'PHP'
<?php

namespace App\Http\Controllers\Api\Rfid;

use App\Http\Controllers\Controller;
use App\Http\Requests\Rfid\RfidVerificationRequest;
use App\Http\Resources\RfidVerificationResource;
use App\Services\RfidVerificationService;
use App\Support\ApiResponse;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class RfidVerificationController extends Controller
{
    public function __construct(private readonly RfidVerificationService $rfid)
    {
    }

    public function verify(RfidVerificationRequest $request): JsonResponse
    {
        $result = $this->rfid->verify(
            $request->user(),
            $request->validated('member_id'),
            $request->file('captured_image'),
        );

        return ApiResponse::resource(new RfidVerificationResource($result), $result->message, 201);
    }

    public function show(Request $request, int $id): JsonResponse
    {
        return ApiResponse::resource(new RfidVerificationResource($this->rfid->show($request->user(), $id)));
    }
}
PHP);

echo "Controllers done\n";
