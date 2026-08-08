<?php

namespace App\Http\Requests\Rfid;

use Illuminate\Foundation\Http\FormRequest;

class RfidVerificationRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'member_id' => ['required', 'string', 'max:100'],
            'timestamp' => ['nullable', 'date'],
            'captured_image' => ['nullable', 'image', 'max:5120'],
        ];
    }
}