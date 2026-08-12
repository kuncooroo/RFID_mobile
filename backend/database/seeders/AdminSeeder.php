<?php

namespace Database\Seeders;

use App\Enums\UserRole;
use App\Models\Cart;
use App\Models\Member;
use App\Models\RfidMember;
use App\Models\User;
use App\Models\UserSetting;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\Hash;

class AdminSeeder extends Seeder
{
    public function run(): void
    {
        $superadmin = User::query()->updateOrCreate(
            ['email' => 'superadmin@kutuku.test'],
            [
                'name' => 'Super Admin',
                'phone' => '+620000000001',
                'password' => Hash::make('password'),
                'role' => UserRole::Superadmin,
                'onboarding_completed_at' => now(),
            ],
        );

        $admins = [
            [
                'email' => 'admin@kutuku.test',
                'name' => 'Admin Kasir 1',
                'phone' => '+620000000002',
            ],
            [
                'email' => 'admin2@kutuku.test',
                'name' => 'Admin Kasir 2',
                'phone' => '+620000000003',
            ],
        ];

        foreach ($admins as $admin) {
            User::query()->updateOrCreate(
                ['email' => $admin['email']],
                [
                    'name' => $admin['name'],
                    'phone' => $admin['phone'],
                    'password' => Hash::make('password'),
                    'role' => UserRole::Admin,
                    'onboarding_completed_at' => now(),
                ],
            );
        }

        $visitors = [
            [
                'name' => 'Budi Santoso',
                'email' => 'budi@kutuku.test',
                'phone' => '+620811100001',
                'member_code' => 'MEM-2001',
                'rfid_uid' => '0182120545',
            ],
            [
                'name' => 'Siti Aminah',
                'email' => 'siti@kutuku.test',
                'phone' => '+620811100002',
                'member_code' => 'MEM-2002',
                'rfid_uid' => '0182120546',
            ],
            [
                'name' => 'Andi Wijaya',
                'email' => 'andi@kutuku.test',
                'phone' => '+620811100003',
                'member_code' => 'MEM-2003',
                'rfid_uid' => '0182120899',
            ],
            [
                'name' => 'Rina Kartika',
                'email' => 'rina@kutuku.test',
                'phone' => '+620811100004',
                'member_code' => 'MEM-2004',
                'rfid_uid' => '0182991001',
            ],
        ];

        foreach ($visitors as $visitorData) {
            $user = User::query()->updateOrCreate(
                ['email' => $visitorData['email']],
                [
                    'name' => $visitorData['name'],
                    'phone' => $visitorData['phone'],
                    'password' => Hash::make('password'),
                    'role' => UserRole::Visitor,
                    'onboarding_completed_at' => now(),
                ],
            );

            Member::query()->updateOrCreate(
                ['user_id' => $user->id],
                [
                    'display_name' => $user->name,
                    'membership_tier' => 'standard',
                    'points' => 100,
                ],
            );

            UserSetting::query()->firstOrCreate(['user_id' => $user->id]);
            Cart::query()->firstOrCreate(
                ['user_id' => $user->id],
                ['currency' => 'USD'],
            );

            RfidMember::query()->updateOrCreate(
                ['rfid_uid' => $visitorData['rfid_uid']],
                [
                    'user_id' => $user->id,
                    'member_code' => $visitorData['member_code'],
                    'is_active' => true,
                ],
            );
        }

        // Ensure classic demo shopper stays a visitor if present.
        User::query()
            ->where('email', 'demo@kutuku.test')
            ->update(['role' => UserRole::Visitor->value]);

        $this->command?->info('AdminSeeder done.');
        $this->command?->line('  superadmin@kutuku.test / password');
        $this->command?->line('  admin@kutuku.test / password');
        $this->command?->line('  admin2@kutuku.test / password');
        $this->command?->line("  Superadmin id={$superadmin->id}");
    }
}
