<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('user_face_enrollments', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained()->cascadeOnDelete();
            $table->string('pose', 16);
            $table->string('image_path');
            $table->timestamp('enrolled_at')->nullable();
            $table->timestamps();

            $table->unique(['user_id', 'pose']);
            $table->index('user_id');
        });

        Schema::table('kiosk_check_ins', function (Blueprint $table) {
            $table->dropForeign(['presence_id']);
        });

        Schema::table('kiosk_check_ins', function (Blueprint $table) {
            $table->unsignedBigInteger('presence_id')->nullable()->change();
            $table->foreign('presence_id')
                ->references('id')
                ->on('kiosk_presences')
                ->nullOnDelete();
        });

        Schema::table('kiosk_presences', function (Blueprint $table) {
            $table->string('photo_path')->nullable()->change();
        });
    }

    public function down(): void
    {
        Schema::table('kiosk_presences', function (Blueprint $table) {
            $table->string('photo_path')->nullable(false)->change();
        });

        Schema::table('kiosk_check_ins', function (Blueprint $table) {
            $table->dropForeign(['presence_id']);
        });

        Schema::table('kiosk_check_ins', function (Blueprint $table) {
            $table->unsignedBigInteger('presence_id')->nullable(false)->change();
            $table->foreign('presence_id')
                ->references('id')
                ->on('kiosk_presences')
                ->cascadeOnDelete();
        });

        Schema::dropIfExists('user_face_enrollments');
    }
};
