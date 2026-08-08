<?php

namespace App\Http\Requests\Auth;

use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Validation\Rule;
use Illuminate\Validation\Rules\Password;

class RegisterRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'name' => ['required', 'string', 'max:120'],
            'email' => ['nullable', 'email', 'max:255', Rule::unique('users', 'email'), 'required_without:phone'],
            'phone' => ['nullable', 'string', 'max:30', Rule::unique('users', 'phone'), 'required_without:email'],
            'password' => ['required', 'confirmed', Password::defaults()],
        ];
    }
}