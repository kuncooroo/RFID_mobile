<?php

namespace App\Repositories;

use App\Contracts\Repositories\SettingsRepositoryInterface;
use App\Models\User;
use App\Models\UserSetting;

class SettingsRepository extends BaseRepository implements SettingsRepositoryInterface
{
    public function __construct(UserSetting $model)
    {
        parent::__construct($model);
    }

    public function forUser(User $user): UserSetting
    {
        return $this->query()->firstOrCreate(
            ['user_id' => $user->id],
            [
                'language_code' => 'en',
                'language_label' => 'English',
                'currency_code' => 'USD',
            ]
        );
    }
}