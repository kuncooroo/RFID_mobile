@extends('admin.layouts.app')

@section('title', 'Experience '.$visitor->name)
@section('heading', $visitor->name)
@section('subheading', 'Gambar experience milik pengunjung ini.')

@section('content')
<div class="toolbar">
    <a class="btn secondary" href="{{ route('admin.experiences.index') }}">Semua pengunjung</a>
    <a class="btn secondary" href="{{ route('admin.visitors.show', $visitor) }}">Detail pengunjung</a>
</div>

<div class="panel" style="margin-bottom: 18px;">
    <div class="panel-header"><h2>Unggah gambar</h2></div>
    <form method="POST" action="{{ route('admin.experiences.store', $visitor) }}" enctype="multipart/form-data" class="form-grid">
        @csrf
        <label>
            Judul
            <input type="text" name="title" value="{{ old('title') }}" placeholder="Kunjungan desa">
        </label>
        <label>
            Catatan
            <input type="text" name="note" value="{{ old('note') }}" placeholder="Opsional">
        </label>
        <label class="full">
            Gambar
            <input type="file" name="images[]" accept="image/*" multiple required>
        </label>
        <div class="full actions">
            <button class="btn" type="submit">Simpan gambar</button>
        </div>
    </form>
</div>

<div class="panel" style="margin-bottom: 18px;">
    <div class="panel-header"><h2>Gambar tersimpan</h2></div>
    @if($experiences->isEmpty())
        <p class="muted">Belum ada gambar yang diunggah untuk pengunjung ini.</p>
    @else
        <div class="gallery">
            @foreach($experiences as $experience)
                <article class="gallery-card">
                    <img src="{{ route('admin.experiences.image', [$visitor, $experience]) }}" alt="{{ $experience->title ?: 'Experience' }}">
                    <div class="meta">
                        <strong>{{ $experience->title ?: 'Tanpa judul' }}</strong>
                        <div class="muted">{{ $experience->created_at?->format('Y-m-d H:i') }}</div>
                        @if($experience->note)
                            <div>{{ $experience->note }}</div>
                        @endif
                        <form method="POST" action="{{ route('admin.experiences.destroy', [$visitor, $experience]) }}" onsubmit="return confirm('Hapus gambar ini?')">
                            @csrf
                            @method('DELETE')
                            <button class="btn danger sm" type="submit">Hapus</button>
                        </form>
                    </div>
                </article>
            @endforeach
        </div>
    @endif
</div>

<div class="panel">
    <div class="panel-header"><h2>Foto dari gerbang</h2></div>
    @if($captures->isEmpty())
        <p class="muted">Belum ada foto yang tertangkap saat tap kartu.</p>
    @else
        <div class="gallery">
            @foreach($captures as $capture)
                <article class="gallery-card">
                    <img src="{{ route('admin.experiences.capture', [$visitor, $capture]) }}" alt="Foto gerbang">
                    <div class="meta">
                        <strong>Tap gerbang</strong>
                        <div class="muted">{{ $capture->captured_at?->format('Y-m-d H:i') }}</div>
                    </div>
                </article>
            @endforeach
        </div>
    @endif
</div>
@endsection
