<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('users', function (Blueprint $table) {
            $table->unsignedSmallInteger('age')->nullable()->after('phone');
            $table->string('origin', 80)->nullable()->after('age');
            $table->string('gender', 16)->nullable()->after('origin');
        });
    }

    public function down(): void
    {
        Schema::table('users', function (Blueprint $table) {
            $table->dropColumn(['age', 'origin', 'gender']);
        });
    }
};
