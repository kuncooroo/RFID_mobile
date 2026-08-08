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