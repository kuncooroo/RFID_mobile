<?php

namespace App\Enums;

enum UserRole: string
{
    case Visitor = 'visitor';
    case Admin = 'admin';
    case Superadmin = 'superadmin';

    public function label(): string
    {
        return match ($this) {
            self::Visitor => 'Visitor',
            self::Admin => 'Admin',
            self::Superadmin => 'Superadmin',
        };
    }

    public function isStaff(): bool
    {
        return $this === self::Admin || $this === self::Superadmin;
    }

    /** @return list<string> */
    public static function staffValues(): array
    {
        return [self::Admin->value, self::Superadmin->value];
    }
}
