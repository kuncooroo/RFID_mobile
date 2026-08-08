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

w("$base/app/Services/OrderService.php", <<<'PHP'
<?php

namespace App\Services;

use App\Contracts\Repositories\OrderRepositoryInterface;
use App\Enums\OrderStatus;
use App\Exceptions\DomainException;
use App\Models\Order;
use App\Models\User;
use Illuminate\Contracts\Pagination\LengthAwarePaginator;

class OrderService
{
    public function __construct(private readonly OrderRepositoryInterface $orders)
    {
    }

    public function active(User $user, int $perPage = 15): LengthAwarePaginator
    {
        return $this->orders->activeForUser($user, $perPage);
    }

    public function history(User $user, int $perPage = 15): LengthAwarePaginator
    {
        return $this->orders->historyForUser($user, $perPage);
    }

    public function show(User $user, int $orderId): Order
    {
        /** @var Order $order */
        $order = $this->orders->findOrFail($orderId);

        if ($order->user_id !== $user->id) {
            throw new DomainException('Order not found.', 404, 'order_not_found');
        }

        return $order->load(['items', 'address', 'paymentMethod', 'trackingEvents']);
    }

    public function track(User $user, int $orderId): Order
    {
        return $this->show($user, $orderId);
    }

    public function cancel(User $user, int $orderId): Order
    {
        $order = $this->show($user, $orderId);

        if (! $order->status->canCancel()) {
            throw new DomainException('This order cannot be cancelled.', 422, 'cannot_cancel');
        }

        return $this->orders->update($order, ['status' => OrderStatus::Cancelled]);
    }
}
PHP);

w("$base/app/Services/AddressService.php", <<<'PHP'
<?php

namespace App\Services;

use App\Contracts\Repositories\AddressRepositoryInterface;
use App\Exceptions\DomainException;
use App\Models\Address;
use App\Models\User;
use Illuminate\Database\Eloquent\Collection;
use Illuminate\Support\Facades\DB;

class AddressService
{
    public function __construct(private readonly AddressRepositoryInterface $addresses)
    {
    }

    public function list(User $user): Collection
    {
        return $this->addresses->forUser($user);
    }

    public function store(User $user, array $data): Address
    {
        return DB::transaction(function () use ($user, $data) {
            if (! empty($data['is_default'])) {
                $this->addresses->clearDefault($user);
            }

            /** @var Address $address */
            $address = $this->addresses->create(array_merge($data, ['user_id' => $user->id]));

            return $address;
        });
    }

    public function update(User $user, int $id, array $data): Address
    {
        /** @var Address $address */
        $address = $this->addresses->findOrFail($id);
        $this->assertOwned($user, $address);

        return DB::transaction(function () use ($user, $address, $data) {
            if (! empty($data['is_default'])) {
                $this->addresses->clearDefault($user);
            }

            return $this->addresses->update($address, $data);
        });
    }

    public function delete(User $user, int $id): void
    {
        /** @var Address $address */
        $address = $this->addresses->findOrFail($id);
        $this->assertOwned($user, $address);
        $this->addresses->delete($address);
    }

    private function assertOwned(User $user, Address $address): void
    {
        if ($address->user_id !== $user->id) {
            throw new DomainException('Address not found.', 404, 'address_not_found');
        }
    }
}
PHP);

w("$base/app/Services/PaymentMethodService.php", <<<'PHP'
<?php

namespace App\Services;

use App\Contracts\Repositories\PaymentMethodRepositoryInterface;
use App\Exceptions\DomainException;
use App\Models\PaymentMethod;
use App\Models\User;
use Illuminate\Database\Eloquent\Collection;
use Illuminate\Support\Facades\DB;

class PaymentMethodService
{
    public function __construct(private readonly PaymentMethodRepositoryInterface $paymentMethods)
    {
    }

    public function list(User $user): Collection
    {
        return $this->paymentMethods->forUser($user);
    }

    public function store(User $user, array $data): PaymentMethod
    {
        return DB::transaction(function () use ($user, $data) {
            if (! empty($data['is_default'])) {
                $this->paymentMethods->clearDefault($user);
            }

            /** @var PaymentMethod $method */
            $method = $this->paymentMethods->create(array_merge($data, ['user_id' => $user->id]));

            return $method;
        });
    }

    public function delete(User $user, int $id): void
    {
        /** @var PaymentMethod $method */
        $method = $this->paymentMethods->findOrFail($id);

        if ($method->user_id !== $user->id) {
            throw new DomainException('Payment method not found.', 404, 'payment_method_not_found');
        }

        $this->paymentMethods->delete($method);
    }
}
PHP);

w("$base/app/Services/ConversationService.php", <<<'PHP'
<?php

namespace App\Services;

use App\Contracts\Repositories\ConversationRepositoryInterface;
use App\Contracts\Repositories\StoreRepositoryInterface;
use App\Exceptions\DomainException;
use App\Models\Conversation;
use App\Models\Message;
use App\Models\User;
use Illuminate\Contracts\Pagination\LengthAwarePaginator;
use Illuminate\Support\Facades\DB;

class ConversationService
{
    public function __construct(
        private readonly ConversationRepositoryInterface $conversations,
        private readonly StoreRepositoryInterface $stores,
    ) {
    }

    public function list(User $user, int $perPage = 15): LengthAwarePaginator
    {
        return $this->conversations->forUser($user, $perPage);
    }

    public function open(User $user, int $storeId): Conversation
    {
        $this->stores->findOrFail($storeId);

        $existing = $this->conversations->findBetweenUserAndStore($user, $storeId);
        if ($existing) {
            return $existing->load(['store', 'messages' => fn ($q) => $q->latest()->limit(1)]);
        }

        return DB::transaction(function () use ($user, $storeId) {
            /** @var Conversation $conversation */
            $conversation = $this->conversations->create([
                'store_id' => $storeId,
                'title' => 'Store chat',
            ]);

            $conversation->participants()->attach($user->id, ['unread_count' => 0]);

            return $conversation->load('store');
        });
    }

    public function messages(User $user, int $conversationId, int $perPage = 30): LengthAwarePaginator
    {
        $conversation = $this->assertParticipant($user, $conversationId);

        return $conversation->messages()->with('sender')->latest()->paginate($perPage);
    }

    public function send(User $user, int $conversationId, array $data): Message
    {
        $conversation = $this->assertParticipant($user, $conversationId);

        return DB::transaction(function () use ($user, $conversation, $data) {
            $message = $conversation->messages()->create([
                'sender_user_id' => $user->id,
                'body' => $data['body'],
                'attachment_path' => $data['attachment_path'] ?? null,
            ]);

            $conversation->update(['last_message_at' => now()]);

            return $message->load('sender');
        });
    }

    public function markRead(User $user, int $conversationId): void
    {
        $conversation = $this->assertParticipant($user, $conversationId);

        $conversation->messages()
            ->whereNull('read_at')
            ->where('sender_user_id', '!=', $user->id)
            ->update(['read_at' => now()]);

        $conversation->participants()->updateExistingPivot($user->id, ['unread_count' => 0]);
    }

    private function assertParticipant(User $user, int $conversationId): Conversation
    {
        /** @var Conversation $conversation */
        $conversation = $this->conversations->findOrFail($conversationId);

        if (! $conversation->participants()->where('users.id', $user->id)->exists()) {
            throw new DomainException('Conversation not found.', 404, 'conversation_not_found');
        }

        return $conversation;
    }
}
PHP);

w("$base/app/Services/NotificationService.php", <<<'PHP'
<?php

namespace App\Services;

use App\Contracts\Repositories\NotificationRepositoryInterface;
use App\Exceptions\DomainException;
use App\Models\AppNotification;
use App\Models\User;
use Illuminate\Contracts\Pagination\LengthAwarePaginator;

class NotificationService
{
    public function __construct(private readonly NotificationRepositoryInterface $notifications)
    {
    }

    public function list(User $user, int $perPage = 20): LengthAwarePaginator
    {
        return $this->notifications->forUser($user, $perPage);
    }

    public function markRead(User $user, int $id): AppNotification
    {
        /** @var AppNotification $notification */
        $notification = $this->notifications->findOrFail($id);

        if ($notification->user_id !== $user->id) {
            throw new DomainException('Notification not found.', 404, 'notification_not_found');
        }

        return $this->notifications->update($notification, ['is_read' => true]);
    }

    public function markAllRead(User $user): int
    {
        return $this->notifications->markAllRead($user);
    }
}
PHP);

w("$base/app/Services/RfidVerificationService.php", <<<'PHP'
<?php

namespace App\Services;

use App\Contracts\Repositories\RfidRepositoryInterface;
use App\Exceptions\DomainException;
use App\Models\RfidVerification;
use App\Models\User;
use Illuminate\Http\UploadedFile;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Storage;

class RfidVerificationService
{
    public function __construct(private readonly RfidRepositoryInterface $rfid)
    {
    }

    public function verify(User $user, string $memberId, ?UploadedFile $image = null): RfidVerification
    {
        $member = $this->rfid->findActiveMember($memberId);

        if (! $member) {
            throw new DomainException('RFID member not found or inactive.', 404, 'rfid_member_not_found');
        }

        return DB::transaction(function () use ($user, $member, $image) {
            $path = null;
            if ($image) {
                $path = $image->store('rfid/captures', 'local');
            }

            $verification = $this->rfid->createVerification([
                'rfid_member_id' => $member->id,
                'user_id' => $user->id,
                'captured_image_path' => $path,
                'gate_opened' => true,
                'status' => 'verified',
                'message' => 'Verification Successful! Gate Opening. Happy Shopping!',
                'verified_at' => now(),
            ]);

            return $verification->load('rfidMember');
        });
    }

    public function show(User $user, int $id): RfidVerification
    {
        $verification = RfidVerification::query()->with('rfidMember')->findOrFail($id);

        if ($verification->user_id !== $user->id) {
            throw new DomainException('Verification not found.', 404, 'verification_not_found');
        }

        return $verification;
    }
}
PHP);

// Fix CheckoutService lockForUpdate issue
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
use App\Models\Product;
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
                /** @var Product $product */
                $product = Product::query()->lockForUpdate()->findOrFail($item->product_id);
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

                $product = Product::query()->lockForUpdate()->findOrFail($item->product_id);
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

echo "Services done\n";
