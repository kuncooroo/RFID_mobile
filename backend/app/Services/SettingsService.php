<?php

namespace App\Services;

use App\Contracts\Repositories\SettingsRepositoryInterface;
use App\Models\User;
use App\Models\UserSetting;

class SettingsService
{
    public function __construct(private readonly SettingsRepositoryInterface $settings)
    {
    }

    public function get(User $user): UserSetting
    {
        return $this->settings->forUser($user);
    }

    public function update(User $user, array $data): UserSetting
    {
        $setting = $this->settings->forUser($user);

        return $this->settings->update($setting, $data);
    }

    /** @return list<array{code:string,label:string}> */
    public function languages(): array
    {
        return [
            ['code' => 'en', 'label' => 'English'],
            ['code' => 'id', 'label' => 'Bahasa Indonesia'],
            ['code' => 'ar', 'label' => 'Arabic'],
            ['code' => 'zh', 'label' => 'Chinese'],
        ];
    }
}