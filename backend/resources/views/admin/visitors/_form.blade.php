@php
    /** @var \App\Models\User|null $visitor */
    $visitor = $visitor ?? null;
    /** @var \Illuminate\Support\Collection<string, \App\Models\UserFaceEnrollment|null> $faces */
    $faces = $faces ?? collect();
    $visitCount = $visitCount ?? 0;
    $isEdit = $visitor !== null;
@endphp

@if($isEdit)
<div class="visitor-meta">
    <div class="visitor-meta-item">
        <span>Points</span>
        <strong>{{ (int) ($visitor->member?->points ?? 0) }}</strong>
    </div>
    <div class="visitor-meta-item">
        <span>Visits</span>
        <strong>{{ $visitCount }}</strong>
    </div>
    <div class="visitor-meta-item">
        <span>Registered</span>
        <strong>{{ $visitor->created_at?->format('Y-m-d H:i') ?? '—' }}</strong>
    </div>
    <div class="visitor-meta-item">
        <span>Face enrollment</span>
        <strong>
            @php
                $enrolled = collect(['front','right','left'])->filter(fn ($p) => filled($faces[$p] ?? null))->count();
            @endphp
            {{ $enrolled }}/3
        </strong>
    </div>
</div>
@endif

<div class="form-section">
    <div class="form-section-head">
        <h3>Profile</h3>
        <p>Data akun visitor untuk aplikasi mobile / kiosk.</p>
    </div>
    <div class="form-grid">
        <label>
            Name
            <input type="text" name="name" value="{{ old('name', $visitor?->name) }}" required autocomplete="name">
        </label>
        <label>
            Password
            <input type="password" name="password" {{ $isEdit ? '' : 'required' }} autocomplete="new-password" placeholder="{{ $isEdit ? 'Leave blank to keep current' : 'Min. 8 characters' }}">
            <span class="help">{{ $isEdit ? 'Optional — isi hanya jika ingin mengganti.' : 'Wajib saat membuat visitor baru.' }}</span>
        </label>
        <label>
            Email
            <input type="email" name="email" value="{{ old('email', $visitor?->email) }}" autocomplete="email">
            <span class="help">Isi email atau phone (minimal salah satu).</span>
        </label>
        <label>
            Phone
            <input type="text" name="phone" value="{{ old('phone', $visitor?->phone) }}" autocomplete="tel">
        </label>
    </div>
</div>

<div class="form-section">
    <div class="form-section-head">
        <h3>RFID card</h3>
        <p>Opsional. Kosongkan RFID UID untuk melepas kartu dari visitor ini.</p>
    </div>
    <div class="form-grid">
        <label>
            RFID UID
            <input type="text" name="rfid_uid" value="{{ old('rfid_uid', $visitor?->rfidMember?->rfid_uid) }}" placeholder="Contoh: 0182120545" autocomplete="off">
        </label>
        <label>
            Member code
            <input type="text" name="member_code" value="{{ old('member_code', $visitor?->rfidMember?->member_code) }}" placeholder="Auto jika kosong">
            <span class="help">Kosongkan untuk generate otomatis.</span>
        </label>
        <label>
            Card status
            <select name="rfid_is_active">
                <option value="1" @selected((string) old('rfid_is_active', $visitor?->rfidMember?->is_active ?? true) === '1')>Active</option>
                <option value="0" @selected((string) old('rfid_is_active', $visitor?->rfidMember?->is_active ?? true) === '0')>Inactive</option>
            </select>
        </label>
    </div>
</div>

<div class="form-section">
    <div class="form-section-head">
        <h3>Face enrollment</h3>
        <p>Foto identitas (Front / Right / Left). Hanya untuk pendaftaran, bukan setiap kunjungan.</p>
    </div>
    <div class="face-upload-grid">
        @foreach(['front' => 'Front', 'right' => 'Right', 'left' => 'Left'] as $pose => $label)
            @php
                $field = 'face_'.$pose;
                $current = $faces[$pose] ?? null;
            @endphp
            <div class="face-upload-card" data-face-card>
                <div class="face-upload-label">{{ $label }}</div>
                <div class="face-upload-preview" data-preview>
                    @if($isEdit && $current)
                        <img src="{{ route('admin.visitors.face', [$visitor, $pose]) }}" alt="{{ $label }}">
                    @else
                        <span class="face-upload-placeholder">Belum ada foto</span>
                    @endif
                </div>
                @if($isEdit && $current)
                    <div class="muted face-upload-meta">
                        {{ $current->enrolled_at?->format('Y-m-d H:i') ?? '—' }}
                    </div>
                @endif
                <label class="face-upload-input">
                    <span>{{ $current ? 'Ganti foto' : 'Pilih foto' }}</span>
                    <input type="file" name="{{ $field }}" accept="image/*" data-face-input>
                </label>
                @if($isEdit && $current)
                    <label class="face-clear">
                        <input type="checkbox" name="clear_{{ $field }}" value="1">
                        Hapus foto ini
                    </label>
                @endif
            </div>
        @endforeach
    </div>
</div>

@push('scripts')
<script>
(function () {
  document.querySelectorAll('[data-face-card]').forEach(function (card) {
    var input = card.querySelector('[data-face-input]');
    var preview = card.querySelector('[data-preview]');
    if (!input || !preview) return;
    input.addEventListener('change', function () {
      var file = input.files && input.files[0];
      if (!file) return;
      var url = URL.createObjectURL(file);
      preview.innerHTML = '';
      var img = document.createElement('img');
      img.src = url;
      img.alt = 'Preview';
      preview.appendChild(img);
    });
  });
})();
</script>
@endpush
