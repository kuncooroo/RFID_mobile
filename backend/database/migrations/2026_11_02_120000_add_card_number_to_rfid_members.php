<?php

use App\Models\RfidMember;
use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('rfid_members', function (Blueprint $table) {
            $table->string('card_number', 16)->nullable()->unique()->after('rfid_uid');
        });

        RfidMember::query()->whereNull('card_number')->orderBy('id')->each(function (RfidMember $card) {
            $card->card_number = RfidMember::generateCardNumber();
            $card->save();
        });
    }

    public function down(): void
    {
        Schema::table('rfid_members', function (Blueprint $table) {
            $table->dropUnique(['card_number']);
            $table->dropColumn('card_number');
        });
    }
};
