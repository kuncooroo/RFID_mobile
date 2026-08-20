<?php

use App\Http\Controllers\Api\Auth\AuthController;
use App\Http\Controllers\Api\Cart\CartController;
use App\Http\Controllers\Api\Catalog\CategoryController;
use App\Http\Controllers\Api\Checkout\AddressController;
use App\Http\Controllers\Api\Checkout\CheckoutController;
use App\Http\Controllers\Api\Checkout\PaymentMethodController;
use App\Http\Controllers\Api\Favorite\FavoriteController;
use App\Http\Controllers\Api\Home\HomeController;
use App\Http\Controllers\Api\Kiosk\KioskController;
use App\Http\Controllers\Api\Messaging\ConversationController;
use App\Http\Controllers\Api\Notification\NotificationController;
use App\Http\Controllers\Api\Order\OrderController;
use App\Http\Controllers\Api\Product\ProductController;
use App\Http\Controllers\Api\Profile\ProfileController;
use App\Http\Controllers\Api\Profile\SettingsController;
use App\Http\Controllers\Api\Rfid\RfidVerificationController;
use App\Http\Controllers\Api\Store\StoreController;
use Illuminate\Support\Facades\Route;

Route::prefix('v1')->group(function () {
    Route::post('/register', [AuthController::class, 'register'])->middleware('throttle:10,1');
    Route::post('/login', [AuthController::class, 'login'])->middleware('throttle:10,1');
    Route::post('/forgot-password', [AuthController::class, 'forgotPassword'])->middleware('throttle:5,1');
    Route::post('/reset-password', [AuthController::class, 'resetPassword'])->middleware('throttle:5,1');

    Route::get('/home', HomeController::class);
    Route::get('/categories', [CategoryController::class, 'index']);
    Route::get('/categories/{category}', [CategoryController::class, 'show']);
    Route::get('/categories/{category}/products', [CategoryController::class, 'products']);
    Route::get('/products', [ProductController::class, 'index']);
    Route::get('/products/{product}', [ProductController::class, 'show']);
    Route::get('/products/{product}/reviews', [ProductController::class, 'reviews']);
    Route::get('/stores/{store}', [StoreController::class, 'show']);
    Route::get('/stores/{store}/products', [StoreController::class, 'products']);
    Route::get('/languages', [SettingsController::class, 'languages']);

    // Public kiosk endpoints (self-service machines). Optional X-Kiosk-Key.
    Route::prefix('kiosk')->middleware(['kiosk.key', 'throttle:60,1'])->group(function () {
        Route::get('/health', [KioskController::class, 'health']);
        Route::post('/rfid/verify', [KioskController::class, 'lookupRfid']);
        Route::post('/verify', [KioskController::class, 'verify']);
        Route::post('/register', [KioskController::class, 'register'])->middleware('throttle:20,1');
        Route::post('/face-enrollment', [KioskController::class, 'enrollFace'])->middleware('throttle:20,1');
        Route::post('/visit', [KioskController::class, 'visit']);
        Route::post('/upload-photo', [KioskController::class, 'uploadPhoto']);
        Route::post('/presence', [KioskController::class, 'recordPresence']);
        Route::post('/check-in', [KioskController::class, 'checkIn']);
    });

    // Aliases matching the kiosk integration contract.
    Route::middleware(['kiosk.key', 'throttle:60,1'])->group(function () {
        Route::post('/verify-kiosk', [KioskController::class, 'verify']);
        Route::post('/upload-photo', [KioskController::class, 'uploadPhoto']);
    });

    // Refresh tokens may only call this endpoint.
    Route::middleware(['auth:sanctum', 'ability:refresh', 'throttle:20,1'])->group(function () {
        Route::post('/refresh', [AuthController::class, 'refresh']);
    });

    // Access tokens for the mobile API surface.
    Route::middleware(['auth:sanctum', 'ability:access'])->group(function () {
        Route::post('/logout', [AuthController::class, 'logout']);

        Route::get('/user', [ProfileController::class, 'me']);
        Route::put('/user/profile', [ProfileController::class, 'update']);
        Route::put('/user/password', [ProfileController::class, 'changePassword']);
        Route::get('/user/settings', [SettingsController::class, 'show']);
        Route::put('/user/settings', [SettingsController::class, 'update']);

        Route::get('/favorites', [FavoriteController::class, 'index']);
        Route::post('/favorites', [FavoriteController::class, 'store']);
        Route::delete('/favorites/{product}', [FavoriteController::class, 'destroy']);
        Route::delete('/favorites', [FavoriteController::class, 'clear']);

        Route::get('/cart', [CartController::class, 'show']);
        Route::post('/cart/items', [CartController::class, 'storeItem']);
        Route::put('/cart/items/{cartItem}', [CartController::class, 'updateItem']);
        Route::delete('/cart/items/{cartItem}', [CartController::class, 'destroyItem']);
        Route::post('/cart/select-all', [CartController::class, 'selectAll']);

        Route::get('/addresses', [AddressController::class, 'index']);
        Route::post('/addresses', [AddressController::class, 'store']);
        Route::put('/addresses/{address}', [AddressController::class, 'update']);
        Route::delete('/addresses/{address}', [AddressController::class, 'destroy']);

        Route::get('/payment-methods', [PaymentMethodController::class, 'index']);
        Route::post('/payment-methods', [PaymentMethodController::class, 'store']);
        Route::delete('/payment-methods/{paymentMethod}', [PaymentMethodController::class, 'destroy']);

        Route::post('/checkout', CheckoutController::class)->middleware('throttle:20,1');
        Route::get('/orders', [OrderController::class, 'index']);
        Route::get('/orders/history', [OrderController::class, 'history']);
        Route::get('/orders/{order}', [OrderController::class, 'show']);
        Route::get('/orders/{order}/track', [OrderController::class, 'track']);
        Route::post('/orders/{order}/cancel', [OrderController::class, 'cancel']);

        Route::get('/conversations', [ConversationController::class, 'index']);
        Route::post('/conversations', [ConversationController::class, 'store']);
        Route::get('/conversations/{conversation}/messages', [ConversationController::class, 'messages']);
        Route::post('/conversations/{conversation}/messages', [ConversationController::class, 'send'])
            ->middleware('throttle:60,1');
        Route::post('/conversations/{conversation}/read', [ConversationController::class, 'markRead']);

        Route::get('/notifications', [NotificationController::class, 'index']);
        Route::post('/notifications/{notification}/read', [NotificationController::class, 'markRead']);
        Route::post('/notifications/read-all', [NotificationController::class, 'markAllRead']);

        Route::post('/reviews', [ProductController::class, 'storeReview']);

        Route::post('/rfid/verify', [RfidVerificationController::class, 'verify'])
            ->middleware('throttle:10,1');
        Route::get('/rfid/verifications/{id}', [RfidVerificationController::class, 'show']);
    });
});
