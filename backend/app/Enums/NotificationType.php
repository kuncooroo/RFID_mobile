<?php

namespace App\Enums;

enum NotificationType: string
{
    case System = 'system';
    case Order = 'order';
    case Promo = 'promo';
    case Chat = 'chat';
    case Payment = 'payment';
}
