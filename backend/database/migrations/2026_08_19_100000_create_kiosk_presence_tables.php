<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('kiosk_locations', function (Blueprint $table) {
            $table->id();
            $table->string('code')->unique();
            $table->string('name');
            $table->boolean('is_active')->default(true);
            $table->timestamps();
        });

        Schema::create('kiosk_presences', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained()->cascadeOnDelete();
            $table->foreignId('rfid_member_id')->constrained('rfid_members')->cascadeOnDelete();
            $table->foreignId('location_id')->constrained('kiosk_locations')->cascadeOnDelete();
            $table->string('device_id')->nullable();
            $table->string('photo_path');
            $table->string('status')->default('verified');
            $table->timestamp('captured_at');
            $table->timestamps();

            $table->index(['user_id', 'captured_at']);
        });

        Schema::create('kiosk_check_ins', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained()->cascadeOnDelete();
            $table->foreignId('rfid_member_id')->constrained('rfid_members')->cascadeOnDelete();
            $table->foreignId('location_id')->constrained('kiosk_locations')->cascadeOnDelete();
            $table->foreignId('presence_id')->constrained('kiosk_presences')->cascadeOnDelete();
            $table->string('status')->default('success');
            $table->unsignedInteger('points_awarded')->default(0);
            $table->timestamp('checked_in_at');
            $table->timestamps();

            $table->index(['user_id', 'checked_in_at']);
            $table->index(['location_id', 'checked_in_at']);
        });

        Schema::create('kiosk_point_ledgers', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained()->cascadeOnDelete();
            $table->foreignId('check_in_id')->nullable()->constrained('kiosk_check_ins')->nullOnDelete();
            $table->integer('delta');
            $table->unsignedInteger('balance_after');
            $table->string('reason');
            $table->timestamps();
        });

        DB::table('kiosk_locations')->insert([
            'code' => 'MAIN',
            'name' => 'Kutuku Main',
            'is_active' => true,
            'created_at' => now(),
            'updated_at' => now(),
        ]);
    }

    public function down(): void
    {
        Schema::dropIfExists('kiosk_point_ledgers');
        Schema::dropIfExists('kiosk_check_ins');
        Schema::dropIfExists('kiosk_presences');
        Schema::dropIfExists('kiosk_locations');
    }
};
