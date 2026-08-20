@extends('admin.layouts.app')

@section('title', 'Admin Management')
@section('heading', 'Admin Management')
@section('subheading', 'Manage admin and superadmin accounts.')

@section('content')
<div class="toolbar">
    <div></div>
    <a class="btn" href="{{ route('admin.staff.create') }}">Add staff</a>
</div>

<div class="panel">
    <div class="table-wrap">
        <table>
            <thead>
            <tr>
                <th>ID</th>
                <th>Name</th>
                <th>Email</th>
                <th>Role</th>
                <th>Actions</th>
            </tr>
            </thead>
            <tbody>
            @foreach($staff as $user)
                <tr>
                    <td>{{ $user->id }}</td>
                    <td><strong>{{ $user->name }}</strong></td>
                    <td>{{ $user->email }}</td>
                    <td><span class="badge neutral">{{ $user->role?->label() }}</span></td>
                    <td class="actions">
                        <a class="btn secondary sm" href="{{ route('admin.staff.edit', $user) }}">Edit</a>
                        @if($user->id !== auth('admin')->id())
                            <form method="POST" action="{{ route('admin.staff.destroy', $user) }}" onsubmit="return confirm('Delete this staff account?')">
                                @csrf
                                @method('DELETE')
                                <button class="btn danger sm" type="submit">Delete</button>
                            </form>
                        @endif
                    </td>
                </tr>
            @endforeach
            </tbody>
        </table>
    </div>
    <div class="pagination">{{ $staff->links('admin.partials.pagination') }}</div>
</div>
@endsection
