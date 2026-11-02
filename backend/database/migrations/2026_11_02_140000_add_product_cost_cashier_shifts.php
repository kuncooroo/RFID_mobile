<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('products', function (Blueprint $table) {
            $table->decimal('cost_amount', 12, 2)->default(0)->after('price');
        });

        Schema::table('order_items', function (Blueprint $table) {
            $table->decimal('cost_amount', 12, 2)->nullable()->after('unit_price');
        });

        Schema::create('cashier_shifts', function (Blueprint $table) {
            $table->id();
            $table->foreignId('admin_id')->constrained('admins')->cascadeOnDelete();
            $table->string('status', 16)->default('open');
            $table->decimal('opening_float', 12, 2)->default(0);
            $table->timestamp('opened_at');
            $table->timestamp('closed_at')->nullable();
            $table->decimal('cash_counted', 12, 2)->nullable();
            $table->string('note', 500)->nullable();
            $table->timestamps();

            $table->index(['admin_id', 'status']);
        });

        Schema::table('wallet_ledgers', function (Blueprint $table) {
            $table->foreignId('admin_id')->nullable()->after('rfid_member_id')->constrained('admins')->nullOnDelete();
            $table->foreignId('shift_id')->nullable()->after('admin_id')->constrained('cashier_shifts')->nullOnDelete();
        });

        $grants = [
            'superadmin' => ['cashier.manage'],
            'admin' => ['cashier.manage'],
            'staff' => ['cashier.manage'],
        ];
        $now = now();
        foreach ($grants as $role => $permissions) {
            foreach ($permissions as $permission) {
                $exists = DB::table('role_permissions')
                    ->where('role', $role)
                    ->where('permission', $permission)
                    ->exists();
                if (! $exists) {
                    DB::table('role_permissions')->insert([
                        'role' => $role,
                        'permission' => $permission,
                        'created_at' => $now,
                        'updated_at' => $now,
                    ]);
                }
            }
        }
    }

    public function down(): void
    {
        Schema::table('wallet_ledgers', function (Blueprint $table) {
            $table->dropConstrainedForeignId('shift_id');
            $table->dropConstrainedForeignId('admin_id');
        });

        Schema::dropIfExists('cashier_shifts');

        Schema::table('order_items', function (Blueprint $table) {
            $table->dropColumn('cost_amount');
        });

        Schema::table('products', function (Blueprint $table) {
            $table->dropColumn('cost_amount');
        });

        DB::table('role_permissions')->where('permission', 'cashier.manage')->delete();
    }
};
