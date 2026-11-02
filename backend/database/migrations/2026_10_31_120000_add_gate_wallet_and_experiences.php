<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('members', function (Blueprint $table) {
            $table->decimal('balance', 12, 2)->default(0)->after('points');
            $table->decimal('discount_credit', 12, 2)->default(0)->after('balance');
        });

        Schema::table('kiosk_locations', function (Blueprint $table) {
            $table->decimal('fare_amount', 12, 2)->default(10000)->after('name');
        });

        Schema::table('kiosk_check_ins', function (Blueprint $table) {
            $table->decimal('amount_charged', 12, 2)->default(0)->after('points_awarded');
            $table->decimal('balance_after', 12, 2)->nullable()->after('amount_charged');
            $table->string('deny_reason')->nullable()->after('balance_after');
        });

        Schema::create('wallet_ledgers', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained()->cascadeOnDelete();
            $table->foreignId('check_in_id')->nullable()->constrained('kiosk_check_ins')->nullOnDelete();
            $table->decimal('delta', 12, 2);
            $table->decimal('balance_after', 12, 2);
            $table->string('reason');
            $table->timestamps();

            $table->index(['user_id', 'created_at']);
        });

        DB::table('kiosk_locations')->update(['fare_amount' => 10000]);

        $demoId = DB::table('users')->where('email', 'demo@wanderdesa.test')->value('id');
        if ($demoId) {
            DB::table('members')->where('user_id', $demoId)->update(['balance' => 100000]);
        }
    }

    public function down(): void
    {
        Schema::dropIfExists('wallet_ledgers');

        Schema::table('kiosk_check_ins', function (Blueprint $table) {
            $table->dropColumn(['amount_charged', 'balance_after', 'deny_reason']);
        });

        Schema::table('kiosk_locations', function (Blueprint $table) {
            $table->dropColumn('fare_amount');
        });

        Schema::table('members', function (Blueprint $table) {
            $table->dropColumn(['balance', 'discount_credit']);
        });
    }
};
