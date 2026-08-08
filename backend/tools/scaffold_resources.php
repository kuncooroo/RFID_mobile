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

// URL helper for media
w("$base/app/Support/MediaUrl.php", <<<'PHP'
<?php

namespace App\Support;

use Illuminate\Support\Facades\Storage;

final class MediaUrl
{
    public static function make(?string $path): ?string
    {
        if ($path === null || $path === '') {
            return null;
        }

        if (str_starts_with($path, 'http://') || str_starts_with($path, 'https://')) {
            return $path;
        }

        return Storage::disk('public')->url($path);
    }
}
PHP);

$resources = [
'UserResource' => <<<'PHP'
<?php

namespace App\Http\Resources;

use App\Support\MediaUrl;
use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

/** @mixin \App\Models\User */
class UserResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'name' => $this->name,
            'email' => $this->email,
            'phone' => $this->phone,
            'avatar_url' => MediaUrl::make($this->avatar_path),
            'onboarding_completed_at' => optional($this->onboarding_completed_at)?->toIso8601String(),
            'member' => MemberResource::make($this->whenLoaded('member')),
            'settings' => SettingsResource::make($this->whenLoaded('settings')),
            'created_at' => optional($this->created_at)?->toIso8601String(),
        ];
    }
}
PHP,
'MemberResource' => <<<'PHP'
<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

/** @mixin \App\Models\Member */
class MemberResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'display_name' => $this->display_name,
            'membership_tier' => $this->membership_tier,
            'points' => $this->points,
            'orders_count' => $this->orders_count,
            'favorites_count' => $this->favorites_count,
            'followers_count' => $this->followers_count,
        ];
    }
}
PHP,
'SettingsResource' => <<<'PHP'
<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

/** @mixin \App\Models\UserSetting */
class SettingsResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'language_code' => $this->language_code,
            'language_label' => $this->language_label,
            'push_notifications_enabled' => $this->push_notifications_enabled,
            'email_notifications_enabled' => $this->email_notifications_enabled,
            'order_updates_enabled' => $this->order_updates_enabled,
            'promo_notifications_enabled' => $this->promo_notifications_enabled,
            'biometric_enabled' => $this->biometric_enabled,
            'two_factor_enabled' => $this->two_factor_enabled,
            'currency_code' => $this->currency_code,
        ];
    }
}
PHP,
'AuthTokenResource' => <<<'PHP'
<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class AuthTokenResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'token' => $this['token'],
            'token_type' => 'Bearer',
            'user' => UserResource::make($this['user']),
        ];
    }
}
PHP,
'CategoryResource' => <<<'PHP'
<?php

namespace App\Http\Resources;

use App\Support\MediaUrl;
use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

/** @mixin \App\Models\Category */
class CategoryResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'name' => $this->name,
            'slug' => $this->slug,
            'image_url' => MediaUrl::make($this->image_path),
            'parent_id' => $this->parent_id,
            'children' => self::collection($this->whenLoaded('children')),
        ];
    }
}
PHP,
'StoreResource' => <<<'PHP'
<?php

namespace App\Http\Resources;

use App\Support\MediaUrl;
use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

/** @mixin \App\Models\Store */
class StoreResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'name' => $this->name,
            'slug' => $this->slug,
            'logo_url' => MediaUrl::make($this->logo_path),
            'banner_url' => MediaUrl::make($this->banner_path),
            'description' => $this->description,
            'is_verified' => $this->is_verified,
            'rating' => (float) $this->rating_avg,
            'location' => $this->location,
            'product_count' => $this->when(isset($this->product_count), $this->product_count),
        ];
    }
}
PHP,
'ProductColorResource' => <<<'PHP'
<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

/** @mixin \App\Models\ProductColor */
class ProductColorResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'name' => $this->name,
            'hex' => $this->hex,
        ];
    }
}
PHP,
'ProductResource' => <<<'PHP'
<?php

namespace App\Http\Resources;

use App\Support\MediaUrl;
use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

/** @mixin \App\Models\Product */
class ProductResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        $images = $this->whenLoaded('images', function () {
            return $this->images->pluck('path')->map(fn ($p) => MediaUrl::make($p))->values();
        }, []);

        return [
            'id' => $this->id,
            'name' => $this->name,
            'slug' => $this->slug,
            'brand' => $this->brand,
            'description' => $this->description,
            'price' => (float) $this->price,
            'discount_price' => $this->discount_price !== null ? (float) $this->discount_price : null,
            'currency' => $this->currency,
            'stock' => $this->stock,
            'rating' => (float) $this->rating_avg,
            'review_count' => $this->reviews_count,
            'image_url' => MediaUrl::make($this->primaryImage()?->path),
            'images' => $images,
            'category_id' => $this->category_id,
            'store_id' => $this->store_id,
            'store' => StoreResource::make($this->whenLoaded('store')),
            'category' => CategoryResource::make($this->whenLoaded('category')),
            'colors' => ProductColorResource::collection($this->whenLoaded('colors')),
            'sizes' => $this->whenLoaded('sizes', fn () => $this->sizes->pluck('label')->values()),
            'is_favorite' => (bool) ($this->is_favorite ?? false),
        ];
    }
}
PHP,
'PromotionResource' => <<<'PHP'
<?php

namespace App\Http\Resources;

use App\Support\MediaUrl;
use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

/** @mixin \App\Models\Promotion */
class PromotionResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'title' => $this->title,
            'subtitle' => $this->subtitle,
            'image_url' => MediaUrl::make($this->image_path),
            'store_id' => $this->store_id,
            'product_id' => $this->product_id,
            'discount_percent' => $this->discount_percent,
            'deep_link' => $this->deep_link,
        ];
    }
}
PHP,
'HomeFeedResource' => <<<'PHP'
<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class HomeFeedResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'promotions' => PromotionResource::collection($this['promotions']),
            'categories' => CategoryResource::collection($this['categories']),
            'new_arrivals' => ProductResource::collection($this['new_arrivals']),
        ];
    }
}
PHP,
'FavoriteResource' => <<<'PHP'
<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

/** @mixin \App\Models\Favorite */
class FavoriteResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'product_id' => $this->product_id,
            'product' => ProductResource::make($this->whenLoaded('product')),
            'created_at' => optional($this->created_at)?->toIso8601String(),
        ];
    }
}
PHP,
'CartItemResource' => <<<'PHP'
<?php

namespace App\Http\Resources;

use App\Support\MediaUrl;
use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

/** @mixin \App\Models\CartItem */
class CartItemResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'product_id' => $this->product_id,
            'name' => $this->name,
            'unit_price' => (float) $this->unit_price,
            'quantity' => $this->quantity,
            'line_total' => (float) $this->line_total,
            'image_url' => MediaUrl::make($this->image_path),
            'brand' => $this->brand,
            'color_name' => $this->color_name,
            'size' => $this->size,
            'is_selected' => $this->is_selected,
            'product' => ProductResource::make($this->whenLoaded('product')),
        ];
    }
}
PHP,
'CartResource' => <<<'PHP'
<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

/** @mixin \App\Models\Cart */
class CartResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        $items = $this->whenLoaded('items') ? $this->items : collect();

        return [
            'id' => $this->id,
            'currency' => $this->currency,
            'items' => CartItemResource::collection($this->whenLoaded('items')),
            'item_count' => $items->sum('quantity'),
            'subtotal' => (float) $items->where('is_selected', true)->sum(fn ($i) => $i->line_total),
        ];
    }
}
PHP,
'AddressResource' => <<<'PHP'
<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

/** @mixin \App\Models\Address */
class AddressResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'label' => $this->label,
            'recipient_name' => $this->recipient_name,
            'phone' => $this->phone,
            'line1' => $this->line1,
            'line2' => $this->line2,
            'city' => $this->city,
            'state' => $this->state,
            'postal_code' => $this->postal_code,
            'country' => $this->country,
            'is_default' => $this->is_default,
        ];
    }
}
PHP,
'PaymentMethodResource' => <<<'PHP'
<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

/** @mixin \App\Models\PaymentMethod */
class PaymentMethodResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'type' => $this->type?->value ?? $this->type,
            'brand' => $this->brand,
            'last4' => $this->last4,
            'holder_name' => $this->holder_name,
            'expiry_month' => $this->expiry_month,
            'expiry_year' => $this->expiry_year,
            'is_default' => $this->is_default,
        ];
    }
}
PHP,
'OrderItemResource' => <<<'PHP'
<?php

namespace App\Http\Resources;

use App\Support\MediaUrl;
use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

/** @mixin \App\Models\OrderItem */
class OrderItemResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'product_id' => $this->product_id,
            'name' => $this->name,
            'unit_price' => (float) $this->unit_price,
            'quantity' => $this->quantity,
            'image_url' => MediaUrl::make($this->image_path),
            'variant_label' => $this->variant_label,
        ];
    }
}
PHP,
'OrderTrackingEventResource' => <<<'PHP'
<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

/** @mixin \App\Models\OrderTrackingEvent */
class OrderTrackingEventResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'title' => $this->title,
            'description' => $this->description,
            'occurred_at' => optional($this->occurred_at)?->toIso8601String(),
            'is_completed' => $this->is_completed,
            'sort_order' => $this->sort_order,
        ];
    }
}
PHP,
'OrderResource' => <<<'PHP'
<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

/** @mixin \App\Models\Order */
class OrderResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'order_number' => $this->order_number,
            'status' => $this->status?->value ?? $this->status,
            'subtotal' => (float) $this->subtotal,
            'shipping_fee' => (float) $this->shipping_fee,
            'discount' => (float) $this->discount,
            'total' => (float) $this->total,
            'currency' => $this->currency,
            'courier_name' => $this->courier_name,
            'tracking_number' => $this->tracking_number,
            'placed_at' => optional($this->placed_at)?->toIso8601String(),
            'items' => OrderItemResource::collection($this->whenLoaded('items')),
            'address' => AddressResource::make($this->whenLoaded('address')),
            'payment_method' => PaymentMethodResource::make($this->whenLoaded('paymentMethod')),
            'tracking_events' => OrderTrackingEventResource::collection($this->whenLoaded('trackingEvents')),
        ];
    }
}
PHP,
'ReviewResource' => <<<'PHP'
<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

/** @mixin \App\Models\Review */
class ReviewResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'product_id' => $this->product_id,
            'rating' => $this->rating,
            'body' => $this->body,
            'user' => UserResource::make($this->whenLoaded('user')),
            'created_at' => optional($this->created_at)?->toIso8601String(),
        ];
    }
}
PHP,
'ConversationResource' => <<<'PHP'
<?php

namespace App\Http\Resources;

use App\Support\MediaUrl;
use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

/** @mixin \App\Models\Conversation */
class ConversationResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        $last = $this->whenLoaded('messages') ? $this->messages->first() : null;
        $user = $request->user();
        $unread = 0;
        if ($user) {
            $pivot = $this->participants->firstWhere('id', $user->id)?->pivot;
            $unread = (int) ($pivot?->unread_count ?? 0);
        }

        return [
            'id' => $this->id,
            'title' => $this->title ?? $this->store?->name,
            'avatar_url' => MediaUrl::make($this->store?->logo_path),
            'store_id' => $this->store_id,
            'last_message' => $last?->body,
            'last_message_at' => optional($this->last_message_at)?->toIso8601String(),
            'unread_count' => $unread,
            'store' => StoreResource::make($this->whenLoaded('store')),
        ];
    }
}
PHP,
'MessageResource' => <<<'PHP'
<?php

namespace App\Http\Resources;

use App\Support\MediaUrl;
use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

/** @mixin \App\Models\Message */
class MessageResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'conversation_id' => $this->conversation_id,
            'sender_user_id' => $this->sender_user_id,
            'body' => $this->body,
            'attachment_url' => MediaUrl::make($this->attachment_path),
            'read_at' => optional($this->read_at)?->toIso8601String(),
            'created_at' => optional($this->created_at)?->toIso8601String(),
            'sender' => UserResource::make($this->whenLoaded('sender')),
        ];
    }
}
PHP,
'NotificationResource' => <<<'PHP'
<?php

namespace App\Http\Resources;

use App\Support\MediaUrl;
use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

/** @mixin \App\Models\AppNotification */
class NotificationResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'title' => $this->title,
            'body' => $this->body,
            'type' => $this->type?->value ?? $this->type,
            'image_url' => MediaUrl::make($this->image_path),
            'is_read' => $this->is_read,
            'reference_type' => $this->reference_type,
            'reference_id' => $this->reference_id,
            'created_at' => optional($this->created_at)?->toIso8601String(),
        ];
    }
}
PHP,
'RfidVerificationResource' => <<<'PHP'
<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

/** @mixin \App\Models\RfidVerification */
class RfidVerificationResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'member_id' => $this->rfidMember?->member_code,
            'gate_opened' => $this->gate_opened,
            'status' => $this->status,
            'message' => $this->message,
            'verified_at' => optional($this->verified_at)?->toIso8601String(),
        ];
    }
}
PHP,
];

foreach ($resources as $name => $body) {
    w("$base/app/Http/Resources/{$name}.php", $body);
}

echo "Resources done\n";
