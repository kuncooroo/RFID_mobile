<?php

namespace App\Models;

use App\Enums\UserRole;
use App\Support\AdminAccess;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Database\Eloquent\SoftDeletes;
use Illuminate\Foundation\Auth\User as Authenticatable;
use Illuminate\Notifications\Notifiable;

class Admin extends Authenticatable
{
    use Notifiable, SoftDeletes;

    protected $fillable = [
        'name',
        'email',
        'phone',
        'password',
        'role',
        'avatar_path',
    ];

    protected $hidden = [
        'password',
        'remember_token',
    ];

    protected function casts(): array
    {
        return [
            'password' => 'hashed',
            'role' => UserRole::class,
        ];
    }

    public function isAdmin(): bool
    {
        return $this->role === UserRole::Admin;
    }

    public function isSuperadmin(): bool
    {
        return $this->role === UserRole::Superadmin;
    }

    public function isStaff(): bool
    {
        return ($this->role ?? UserRole::Admin)->isStaff();
    }

    public function allows(string $permission): bool
    {
        if ($this->isSuperadmin()) {
            return array_key_exists($permission, AdminAccess::catalog());
        }

        $role = $this->role?->value;
        if ($role === null) {
            return false;
        }

        return in_array($permission, $this->permissionKeys(), true);
    }

    /**
     * @return list<string>
     */
    public function permissionKeys(): array
    {
        if ($this->isSuperadmin()) {
            return array_keys(AdminAccess::catalog());
        }

        return once(function () {
            return RolePermission::query()
                ->where('role', $this->role?->value)
                ->pluck('permission')
                ->all();
        });
    }

    public function activityLogs(): HasMany
    {
        return $this->hasMany(AdminActivityLog::class);
    }
}
