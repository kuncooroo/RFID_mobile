<?php

namespace Tests\Feature;

use App\Enums\UserRole;
use App\Models\KioskCheckIn;
use App\Models\KioskLocation;
use App\Models\KioskPointLedger;
use App\Models\Member;
use App\Models\RfidMember;
use App\Models\User;
use App\Models\UserFaceEnrollment;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Http\UploadedFile;
use Illuminate\Support\Facades\Storage;
use Tests\TestCase;

class KioskVisitEnrollmentTest extends TestCase
{
    use RefreshDatabase;

    protected function setUp(): void
    {
        parent::setUp();
        Storage::fake('local');
        config(['kiosk.checkin_points' => 10, 'kiosk.scan_cooldown_seconds' => 60]);

        if (! KioskLocation::query()->where('is_active', true)->exists()) {
            KioskLocation::query()->create([
                'code' => 'MAIN',
                'name' => 'Main',
                'is_active' => true,
            ]);
        }
    }

    public function test_face_enrollment_stores_three_poses(): void
    {
        [$user, $rfid] = $this->seedBoundMember();

        $response = $this->post('/api/v1/kiosk/face-enrollment', [
            'rfid_uid' => $rfid->rfid_uid,
            'front' => UploadedFile::fake()->image('front.jpg'),
            'right' => UploadedFile::fake()->image('right.jpg'),
            'left' => UploadedFile::fake()->image('left.jpg'),
        ]);

        $response->assertCreated()->assertJsonPath('success', true);
        $this->assertSame(3, UserFaceEnrollment::query()->where('user_id', $user->id)->count());
    }

    public function test_visit_awards_points_without_photo(): void
    {
        [$user, $rfid] = $this->seedBoundMember();

        $response = $this->postJson('/api/v1/kiosk/visit', [
            'rfid_uid' => $rfid->rfid_uid,
        ]);

        $response->assertOk()
            ->assertJsonPath('success', true)
            ->assertJsonPath('data.points.earned', 10);

        $this->assertSame(1, KioskCheckIn::query()->where('user_id', $user->id)->count());
        $this->assertSame(1, KioskPointLedger::query()->where('user_id', $user->id)->count());
        $this->assertSame(10, (int) Member::query()->where('user_id', $user->id)->value('points'));
    }

    public function test_duplicate_scan_within_cooldown_does_not_create_visit(): void
    {
        [$user, $rfid] = $this->seedBoundMember();

        $this->postJson('/api/v1/kiosk/visit', ['rfid_uid' => $rfid->rfid_uid])->assertOk();
        $second = $this->postJson('/api/v1/kiosk/visit', ['rfid_uid' => $rfid->rfid_uid]);

        $second->assertOk()
            ->assertJsonPath('data.duplicate', true)
            ->assertJsonPath('data.points.earned', 0);

        $this->assertSame(1, KioskCheckIn::query()->where('user_id', $user->id)->count());
        $this->assertSame(10, (int) Member::query()->where('user_id', $user->id)->value('points'));
    }

    public function test_invalid_rfid_visit_fails(): void
    {
        $response = $this->postJson('/api/v1/kiosk/visit', [
            'rfid_uid' => 'UNKNOWN-CARD-999',
        ]);

        $response->assertStatus(422);
        $this->assertSame(0, KioskCheckIn::query()->count());
    }

    /**
     * @return array{0:User,1:RfidMember}
     */
    private function seedBoundMember(): array
    {
        $user = User::query()->create([
            'name' => 'Muhammad',
            'email' => 'muhammad@example.com',
            'password' => 'password',
            'role' => UserRole::Visitor,
            'onboarding_completed_at' => now(),
        ]);

        Member::query()->create([
            'user_id' => $user->id,
            'display_name' => $user->name,
            'points' => 0,
        ]);

        $rfid = RfidMember::query()->create([
            'user_id' => $user->id,
            'member_code' => 'KUTUKU-001',
            'rfid_uid' => '0182120545',
            'is_active' => true,
        ]);

        return [$user, $rfid];
    }
}
