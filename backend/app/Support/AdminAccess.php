<?php

namespace App\Support;

class AdminAccess
{
    /**
     * @return array<string, string>
     */
    public static function catalog(): array
    {
        return [
            'dashboard.view' => 'Dashboard',
            'visitors.manage' => 'Pengunjung',
            'experiences.manage' => 'Experience',
            'rfid.manage' => 'RFID',
            'products.manage' => 'Produk',
            'orders.manage' => 'Pesanan',
            'analytics.view' => 'Analitik',
            'finance.manage' => 'Keuangan',
            'cashier.manage' => 'Kasir dan shift',
            'staff.manage' => 'Akun staf',
            'permissions.manage' => 'Izin peran',
            'activity.view' => 'Log aktivitas',
        ];
    }

    /**
     * @return array<string, list<string>>
     */
    public static function defaults(): array
    {
        $all = array_keys(self::catalog());

        return [
            'superadmin' => $all,
            'finance' => [
                'dashboard.view',
                'experiences.manage',
                'orders.manage',
                'analytics.view',
                'finance.manage',
            ],
            'staff' => [
                'dashboard.view',
                'visitors.manage',
                'experiences.manage',
                'rfid.manage',
                'cashier.manage',
            ],
            'admin' => array_values(array_diff($all, [
                'finance.manage',
                'staff.manage',
                'permissions.manage',
            ])),
        ];
    }
}
