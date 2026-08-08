<?php

namespace App\Enums;

enum PaymentMethodType: string
{
    case Card = 'card';
    case Wallet = 'wallet';
}
