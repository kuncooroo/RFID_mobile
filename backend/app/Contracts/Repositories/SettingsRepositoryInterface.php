<?php

namespace App\Contracts\Repositories;

use App\Models\User;
use App\Models\UserSetting;

interface SettingsRepositoryInterface extends BaseRepositoryInterface
{
    public function forUser(User $user): UserSetting;
}