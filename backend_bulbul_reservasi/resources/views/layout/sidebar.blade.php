<nav class="sidebar sidebar-offcanvas dynamic-active-class-disabled" id="sidebar">
  <ul class="nav">

    <li class="nav-item nav-profile not-navigation-link">
      <div class="nav-link">
        <div class="user-wrapper">
          <div class="profile-image">
            <img src="{{ url('assets/images/faces/face8.jpg') }}" alt="profile image">
          </div>
          <div class="text-wrapper">
            <p class="profile-name">Richard V.Welsh</p>
            <div class="dropdown" data-display="static">
              <a href="#" class="nav-link d-flex user-switch-dropdown-toggler" id="UsersettingsDropdown" data-toggle="dropdown">
                <small class="designation text-muted">Manager</small>
                <span class="status-indicator online"></span>
              </a>
              <div class="dropdown-menu" aria-labelledby="UsersettingsDropdown">
                <a class="dropdown-item mt-2"> Manage Accounts </a>
                <a class="dropdown-item"> Change Password </a>
                <a class="dropdown-item"> Check Inbox </a>
                <a class="dropdown-item"> Sign Out </a>
              </div>
            </div>
          </div>
        </div>
        <button class="btn btn-success btn-block">New Project <i class="mdi mdi-plus"></i>
        </button>
      </div>
    </li>

    {{-- Dashboard --}}
    <li class="nav-item {{ request()->is('/') ? 'active' : '' }}">
      <a class="nav-link" href="{{ url('/') }}">
        <i class="menu-icon mdi mdi-television"></i>
        <span class="menu-title">Dashboard</span>
      </a>
    </li>

    {{-- Basic UI (with submenu) --}}
    <li class="nav-item {{ request()->is('basic-ui/*') ? 'active' : '' }}">
      <a class="nav-link" data-toggle="collapse" href="#basic-ui"
         aria-expanded="{{ request()->is('basic-ui/*') ? 'true' : 'false' }}">
        <i class="menu-icon mdi mdi-dna"></i>
        <span class="menu-title">Basic UI Elements</span>
        <i class="menu-arrow"></i>
      </a>
      <div class="collapse {{ request()->is('basic-ui/*') ? 'show' : '' }}" id="basic-ui">
        <ul class="nav flex-column sub-menu">

          <li class="nav-item {{ request()->is('basic-ui/buttons') ? 'active' : '' }}">
            <a class="nav-link" href="{{ url('/basic-ui/buttons') }}">Buttons</a>
          </li>

          <li class="nav-item {{ request()->is('basic-ui/dropdowns') ? 'active' : '' }}">
            <a class="nav-link" href="{{ url('/basic-ui/dropdowns') }}">Dropdowns</a>
          </li>

          <li class="nav-item {{ request()->is('basic-ui/typography') ? 'active' : '' }}">
            <a class="nav-link" href="{{ url('/basic-ui/typography') }}">Typography</a>
          </li>

        </ul>
      </div>
    </li>

    {{-- Charts --}}
    <li class="nav-item {{ request()->is('charts/chartjs') ? 'active' : '' }}">
      <a class="nav-link" href="{{ url('/charts/chartjs') }}">
        <i class="menu-icon mdi mdi-chart-line"></i>
        <span class="menu-title">Charts</span>
      </a>
    </li>

    {{-- Tables --}}
    <li class="nav-item {{ request()->is('tables/basic-table') ? 'active' : '' }}">
      <a class="nav-link" href="{{ url('/tables/basic-table') }}">
        <i class="menu-icon mdi mdi-table-large"></i>
        <span class="menu-title">Tables</span>
      </a>
    </li>

    {{-- Icons --}}
    <li class="nav-item {{ request()->is('icons/material') ? 'active' : '' }}">
      <a class="nav-link" href="{{ url('/icons/material') }}">
        <i class="menu-icon mdi mdi-emoticon"></i>
        <span class="menu-title">Icons</span>
      </a>
    </li>

    {{-- User Pages --}}
    <li class="nav-item {{ request()->is('user-pages/*') ? 'active' : '' }}">
      <a class="nav-link" data-toggle="collapse" href="#user-pages"
         aria-expanded="{{ request()->is('user-pages/*') ? 'true' : 'false' }}">
        <i class="menu-icon mdi mdi-lock-outline"></i>
        <span class="menu-title">User Pages</span>
        <i class="menu-arrow"></i>
      </a>
      <div class="collapse {{ request()->is('user-pages/*') ? 'show' : '' }}" id="user-pages">
        <ul class="nav flex-column sub-menu">

          <li class="nav-item {{ request()->is('user-pages/login') ? 'active' : '' }}">
            <a class="nav-link" href="{{ url('/user-pages/login') }}">Login</a>
          </li>

          <li class="nav-item {{ request()->is('user-pages/register') ? 'active' : '' }}">
            <a class="nav-link" href="{{ url('/user-pages/register') }}">Register</a>
          </li>

          <li class="nav-item {{ request()->is('user-pages/lock-screen') ? 'active' : '' }}">
            <a class="nav-link" href="{{ url('/user-pages/lock-screen') }}">Lock Screen</a>
          </li>

        </ul>
      </div>
    </li>

    <li class="nav-item">
      <a class="nav-link" href="https://www.bootstrapdash.com/demo/star-laravel-free/documentation/documentation.html" target="_blank">
        <i class="menu-icon mdi mdi-file-outline"></i>
        <span class="menu-title">Documentation</span>
      </a>
    </li>

  </ul>
</nav>
