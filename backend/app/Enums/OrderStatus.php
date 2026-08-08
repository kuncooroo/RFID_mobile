<?php

namespace App\Enums;

enum OrderStatus: string
{
    case Pending = 'pending';
    case Paid = 'paid';
    case Processing = 'processing';
    case Shipped = 'shipped';
    case Delivered = 'delivered';
    case Cancelled = 'cancelled';
    case Refunded = 'refunded';

    public function isActive(): bool
    {
        return in_array($this, [
            self::Pending,
            self::Paid,
            self::Processing,
            self::Shipped,
        ], true);
    }

    public function canCancel(): bool
    {
        return in_array($this, [self::Pending, self::Paid], true);
    }
}
