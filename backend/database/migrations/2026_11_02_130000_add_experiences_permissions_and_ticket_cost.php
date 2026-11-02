<?php

use App\Support\AdminAccess;
use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('kiosk_locations', function (Blueprint $table) {
            $table->decimal('cost_amount', 12, 2)->default(4000)->after('fare_amount');
        });

        Schema::create('user_experiences', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained()->cascadeOnDelete();
            $table->string('title')->nullable();
            $table->string('image_path');
            $table->text('note')->nullable();
            $table->foreignId('admin_id')->nullable()->constrained('admins')->nullOnDelete();
            $table->timestamps();
        });

        Schema::create('role_permissions', function (Blueprint $table) {
            $table->id();
            $table->string('role', 32);
            $table->string('permission', 64);
            $table->timestamps();

            $table->unique(['role', 'permission']);
        });

        $now = now();
        $rows = [];
        foreach (AdminAccess::defaults() as $role => $permissions) {
            foreach ($permissions as $permission) {
                $rows[] = [
                    'role' => $role,
                    'permission' => $permission,
                    'created_at' => $now,
                    'updated_at' => $now,
                ];
            }
        }
        DB::table('role_permissions')->insert($rows);

        DB::table('stores')->where('slug', 'tap'.'go-official')->update([
            'name' => 'WanderDesa Official',
            'slug' => 'wanderdesa-official',
            'description' => 'Official WanderDesa store',
        ]);

        $fromDomain = 'tap'.'go.test';
        foreach (['admins', 'users'] as $table) {
            $people = DB::table($table)->where('email', 'like', '%@'.$fromDomain)->get(['id', 'email']);
            foreach ($people as $person) {
                DB::table($table)->where('id', $person->id)->update([
                    'email' => str_replace('@'.$fromDomain, '@wanderdesa.test', $person->email),
                ]);
            }
        }

        $accounts = [
            ['email' => 'keuangan@wanderdesa.test', 'name' => 'Keuangan', 'role' => 'finance', 'phone' => '+620000000010'],
            ['email' => 'staff@wanderdesa.test', 'name' => 'Staff Lapangan', 'role' => 'staff', 'phone' => '+620000000011'],
        ];

        foreach ($accounts as $account) {
            $exists = DB::table('admins')->where('email', $account['email'])->exists();
            if ($exists) {
                continue;
            }

            DB::table('admins')->insert([
                'name' => $account['name'],
                'email' => $account['email'],
                'phone' => $account['phone'],
                'password' => Hash::make('password'),
                'role' => $account['role'],
                'created_at' => $now,
                'updated_at' => $now,
            ]);
        }
    }

    public function down(): void
    {
        Schema::dropIfExists('role_permissions');
        Schema::dropIfExists('user_experiences');

        Schema::table('kiosk_locations', function (Blueprint $table) {
            $table->dropColumn('cost_amount');
        });
    }
};
