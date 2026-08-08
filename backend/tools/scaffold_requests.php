<?php

$base = dirname(__DIR__);
function w(string $path, string $contents): void
{
    $dir = dirname($path);
    if (! is_dir($dir)) {
        mkdir($dir, 0777, true);
    }
    file_put_contents($path, $contents);
    echo basename($path)."\n";
}

$requests = [
'Auth/RegisterRequest' => <<<'PHP'
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
PHP,
'Auth/LoginRequest' => <<<'PHP'
<?php

namespace App\Http\Requests\Auth;

use Illuminate\Foundation\Http\FormRequest;

class LoginRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'identifier' => ['required', 'string', 'max:255'],
            'password' => ['required', 'string'],
            'device_name' => ['nullable', 'string', 'max:100'],
        ];
    }
}
PHP,
'Auth/ForgotPasswordRequest' => <<<'PHP'
<?php

namespace App\Http\Requests\Auth;

use Illuminate\Foundation\Http\FormRequest;

class ForgotPasswordRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'email' => ['required', 'email', 'exists:users,email'],
        ];
    }
}
PHP,
'Auth/ResetPasswordRequest' => <<<'PHP'
<?php

namespace App\Http\Requests\Auth;

use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Validation\Rules\Password;

class ResetPasswordRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'email' => ['required', 'email'],
            'token' => ['required', 'string'],
            'password' => ['required', 'confirmed', Password::defaults()],
        ];
    }
}
PHP,
'Profile/UpdateProfileRequest' => <<<'PHP'
<?php

namespace App\Http\Requests\Profile;

use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Validation\Rule;

class UpdateProfileRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        $userId = $this->user()?->id;

        return [
            'name' => ['sometimes', 'string', 'max:120'],
            'email' => ['sometimes', 'email', 'max:255', Rule::unique('users', 'email')->ignore($userId)],
            'phone' => ['nullable', 'string', 'max:30', Rule::unique('users', 'phone')->ignore($userId)],
            'avatar_path' => ['nullable', 'string', 'max:255'],
        ];
    }
}
PHP,
'Profile/ChangePasswordRequest' => <<<'PHP'
<?php

namespace App\Http\Requests\Profile;

use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Validation\Rules\Password;

class ChangePasswordRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'current_password' => ['required', 'string'],
            'password' => ['required', 'confirmed', Password::defaults()],
        ];
    }
}
PHP,
'Settings/UpdateSettingsRequest' => <<<'PHP'
<?php

namespace App\Http\Requests\Settings;

use Illuminate\Foundation\Http\FormRequest;

class UpdateSettingsRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'language_code' => ['sometimes', 'string', 'max:10'],
            'language_label' => ['sometimes', 'string', 'max:100'],
            'push_notifications_enabled' => ['sometimes', 'boolean'],
            'email_notifications_enabled' => ['sometimes', 'boolean'],
            'order_updates_enabled' => ['sometimes', 'boolean'],
            'promo_notifications_enabled' => ['sometimes', 'boolean'],
            'biometric_enabled' => ['sometimes', 'boolean'],
            'two_factor_enabled' => ['sometimes', 'boolean'],
            'currency_code' => ['sometimes', 'string', 'size:3'],
        ];
    }
}
PHP,
'Search/ProductSearchRequest' => <<<'PHP'
<?php

namespace App\Http\Requests\Search;

use Illuminate\Foundation\Http\FormRequest;

class ProductSearchRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'q' => ['nullable', 'string', 'max:200'],
            'category_id' => ['nullable', 'integer', 'exists:categories,id'],
            'store_id' => ['nullable', 'integer', 'exists:stores,id'],
            'min_price' => ['nullable', 'numeric', 'min:0'],
            'max_price' => ['nullable', 'numeric', 'min:0'],
            'color_ids' => ['nullable', 'array'],
            'color_ids.*' => ['integer', 'exists:product_colors,id'],
            'locations' => ['nullable', 'array'],
            'locations.*' => ['string', 'max:120'],
            'sort' => ['nullable', 'in:all,price_asc,price_desc,rating,newest'],
            'per_page' => ['nullable', 'integer', 'min:1', 'max:50'],
        ];
    }
}
PHP,
'Favorite/StoreFavoriteRequest' => <<<'PHP'
<?php

namespace App\Http\Requests\Favorite;

use Illuminate\Foundation\Http\FormRequest;

class StoreFavoriteRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'product_id' => ['required', 'integer', 'exists:products,id'],
        ];
    }
}
PHP,
'Cart/StoreCartItemRequest' => <<<'PHP'
<?php

namespace App\Http\Requests\Cart;

use Illuminate\Foundation\Http\FormRequest;

class StoreCartItemRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'product_id' => ['required', 'integer', 'exists:products,id'],
            'quantity' => ['nullable', 'integer', 'min:1', 'max:99'],
            'color_name' => ['nullable', 'string', 'max:50'],
            'size' => ['nullable', 'string', 'max:20'],
        ];
    }
}
PHP,
'Cart/UpdateCartItemRequest' => <<<'PHP'
<?php

namespace App\Http\Requests\Cart;

use Illuminate\Foundation\Http\FormRequest;

class UpdateCartItemRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'quantity' => ['sometimes', 'integer', 'min:1', 'max:99'],
            'is_selected' => ['sometimes', 'boolean'],
        ];
    }
}
PHP,
'Cart/SelectAllCartRequest' => <<<'PHP'
<?php

namespace App\Http\Requests\Cart;

use Illuminate\Foundation\Http\FormRequest;

class SelectAllCartRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'selected' => ['required', 'boolean'],
        ];
    }
}
PHP,
'Checkout/StoreAddressRequest' => <<<'PHP'
<?php

namespace App\Http\Requests\Checkout;

use Illuminate\Foundation\Http\FormRequest;

class StoreAddressRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'label' => ['nullable', 'string', 'max:50'],
            'recipient_name' => ['required', 'string', 'max:120'],
            'phone' => ['required', 'string', 'max:30'],
            'line1' => ['required', 'string', 'max:255'],
            'line2' => ['nullable', 'string', 'max:255'],
            'city' => ['required', 'string', 'max:100'],
            'state' => ['nullable', 'string', 'max:100'],
            'postal_code' => ['nullable', 'string', 'max:20'],
            'country' => ['nullable', 'string', 'max:2'],
            'is_default' => ['sometimes', 'boolean'],
        ];
    }
}
PHP,
'Checkout/StorePaymentMethodRequest' => <<<'PHP'
<?php

namespace App\Http\Requests\Checkout;

use Illuminate\Foundation\Http\FormRequest;

class StorePaymentMethodRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'type' => ['required', 'in:card,wallet'],
            'brand' => ['nullable', 'string', 'max:50'],
            'last4' => ['nullable', 'string', 'size:4'],
            'holder_name' => ['nullable', 'string', 'max:120'],
            'expiry_month' => ['nullable', 'integer', 'between:1,12'],
            'expiry_year' => ['nullable', 'integer', 'min:2024'],
            'provider_token' => ['required', 'string', 'max:255'],
            'is_default' => ['sometimes', 'boolean'],
        ];
    }
}
PHP,
'Checkout/CheckoutRequest' => <<<'PHP'
<?php

namespace App\Http\Requests\Checkout;

use Illuminate\Foundation\Http\FormRequest;

class CheckoutRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'address_id' => ['required', 'integer', 'exists:addresses,id'],
            'payment_method_id' => ['required', 'integer', 'exists:payment_methods,id'],
            'shipping_fee' => ['nullable', 'numeric', 'min:0'],
            'discount' => ['nullable', 'numeric', 'min:0'],
        ];
    }
}
PHP,
'Product/StoreReviewRequest' => <<<'PHP'
<?php

namespace App\Http\Requests\Product;

use Illuminate\Foundation\Http\FormRequest;

class StoreReviewRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'product_id' => ['required', 'integer', 'exists:products,id'],
            'rating' => ['required', 'integer', 'between:1,5'],
            'body' => ['nullable', 'string', 'max:2000'],
        ];
    }
}
PHP,
'Messaging/StoreMessageRequest' => <<<'PHP'
<?php

namespace App\Http\Requests\Messaging;

use Illuminate\Foundation\Http\FormRequest;

class StoreMessageRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'body' => ['required', 'string', 'max:5000'],
            'attachment_path' => ['nullable', 'string', 'max:255'],
        ];
    }
}
PHP,
'Messaging/OpenConversationRequest' => <<<'PHP'
<?php

namespace App\Http\Requests\Messaging;

use Illuminate\Foundation\Http\FormRequest;

class OpenConversationRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'store_id' => ['required', 'integer', 'exists:stores,id'],
        ];
    }
}
PHP,
'Rfid/RfidVerificationRequest' => <<<'PHP'
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
PHP,
];

foreach ($requests as $rel => $body) {
    w("$base/app/Http/Requests/{$rel}.php", $body);
}

echo "Requests done\n";
