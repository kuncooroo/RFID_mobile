<?php

namespace App\Providers;

use App\Contracts\Repositories\AddressRepositoryInterface;
use App\Contracts\Repositories\CartRepositoryInterface;
use App\Contracts\Repositories\CategoryRepositoryInterface;
use App\Contracts\Repositories\ConversationRepositoryInterface;
use App\Contracts\Repositories\FavoriteRepositoryInterface;
use App\Contracts\Repositories\NotificationRepositoryInterface;
use App\Contracts\Repositories\OrderRepositoryInterface;
use App\Contracts\Repositories\PaymentMethodRepositoryInterface;
use App\Contracts\Repositories\ProductRepositoryInterface;
use App\Contracts\Repositories\PromotionRepositoryInterface;
use App\Contracts\Repositories\ReviewRepositoryInterface;
use App\Contracts\Repositories\RfidRepositoryInterface;
use App\Contracts\Repositories\SettingsRepositoryInterface;
use App\Contracts\Repositories\StoreRepositoryInterface;
use App\Contracts\Repositories\UserRepositoryInterface;
use App\Models\Address;
use App\Models\Conversation;
use App\Models\Order;
use App\Policies\AddressPolicy;
use App\Policies\ConversationPolicy;
use App\Policies\OrderPolicy;
use App\Repositories\AddressRepository;
use App\Repositories\CartRepository;
use App\Repositories\CategoryRepository;
use App\Repositories\ConversationRepository;
use App\Repositories\FavoriteRepository;
use App\Repositories\NotificationRepository;
use App\Repositories\OrderRepository;
use App\Repositories\PaymentMethodRepository;
use App\Repositories\ProductRepository;
use App\Repositories\PromotionRepository;
use App\Repositories\ReviewRepository;
use App\Repositories\RfidRepository;
use App\Repositories\SettingsRepository;
use App\Repositories\StoreRepository;
use App\Repositories\UserRepository;
use Illuminate\Support\Facades\Gate;
use Illuminate\Support\ServiceProvider;

class RepositoryServiceProvider extends ServiceProvider
{
    /** @var array<class-string, class-string> */
    public array $bindings = [
        UserRepositoryInterface::class => UserRepository::class,
        ProductRepositoryInterface::class => ProductRepository::class,
        CategoryRepositoryInterface::class => CategoryRepository::class,
        StoreRepositoryInterface::class => StoreRepository::class,
        PromotionRepositoryInterface::class => PromotionRepository::class,
        FavoriteRepositoryInterface::class => FavoriteRepository::class,
        CartRepositoryInterface::class => CartRepository::class,
        AddressRepositoryInterface::class => AddressRepository::class,
        PaymentMethodRepositoryInterface::class => PaymentMethodRepository::class,
        OrderRepositoryInterface::class => OrderRepository::class,
        ConversationRepositoryInterface::class => ConversationRepository::class,
        NotificationRepositoryInterface::class => NotificationRepository::class,
        RfidRepositoryInterface::class => RfidRepository::class,
        ReviewRepositoryInterface::class => ReviewRepository::class,
        SettingsRepositoryInterface::class => SettingsRepository::class,
    ];

    public function boot(): void
    {
        Gate::policy(Address::class, AddressPolicy::class);
        Gate::policy(Order::class, OrderPolicy::class);
        Gate::policy(Conversation::class, ConversationPolicy::class);
    }
}
