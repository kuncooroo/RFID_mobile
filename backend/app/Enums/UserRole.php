<?php

namespace App\Enums;

enum UserRole: string
{
    case Visitor = 'visitor';
    case Admin = 'admin';
    case Superadmin = 'superadmin';
    case Finance = 'finance';
    case Staff = 'staff';

    public function label(): string
    {
        return match ($this) {
            self::Visitor => 'Pengunjung',
            self::Admin => 'Admin',
            self::Superadmin => 'Superadmin',
            self::Finance => 'Keuangan',
            self::Staff => 'Staff',
        };
    }

    public function isStaff(): bool
    {
        return $this !== self::Visitor;
    }

    /** @return list<string> */
    public static function staffValues(): array
    {
        return array_values(array_map(
            fn (self $role) => $role->value,
            array_filter(self::cases(), fn (self $role) => $role->isStaff()),
        ));
    }
}
