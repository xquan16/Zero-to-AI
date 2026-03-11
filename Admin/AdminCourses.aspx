<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="AdminCourses.aspx.cs" Inherits="Zero_to_AI.Admin.AdminCourses" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
    <link href="https://fonts.googleapis.com/css2?family=Outfit:wght@400;500;600;700;800&family=DM+Sans:ital,opsz,wght@0,9..40,400;0,9..40,500;1,9..40,400&display=swap" rel="stylesheet">
    <style>
        /* ── SHARED TOKEN LAYER ─────────────────────────────── */
        .aw { --accent: #d97706; --accent-2: #ea580c; --accent-soft: rgba(217,119,6,.10);
              --accent-glow: rgba(217,119,6,.22); font-family:'DM Sans',sans-serif; }

        /* ── HERO ───────────────────────────────────────────── */
        .aw .page-hero {
            position:relative; overflow:hidden;
            background:linear-gradient(135deg, var(--bg-card,#fff) 0%, var(--accent-soft) 100%);
            border:1px solid var(--border-color,#e2e8f0);
            border-radius:20px; padding:36px 40px 30px; margin-bottom:28px;
        }
        .aw .page-hero::before {
            content:''; position:absolute; inset:0; pointer-events:none;
            background:radial-gradient(ellipse 60% 80% at 90% 50%, var(--accent-glow), transparent);
        }
        .aw .hero-eyebrow {
            display:inline-flex; align-items:center; gap:6px;
            background:var(--accent-soft); color:var(--accent);
            font-family:'Outfit',sans-serif; font-size:.72rem; font-weight:700;
            letter-spacing:.08em; text-transform:uppercase;
            padding:4px 12px; border-radius:20px; margin-bottom:12px;
        }
        .aw .page-hero h1 {
            font-family:'Outfit',sans-serif; font-size:2rem; font-weight:800;
            color:var(--text-main,#0f172a); margin:0 0 8px; line-height:1.15;
        }
        .aw .page-hero h1 mark {
            background:none; -webkit-text-fill-color:transparent;
            background-image:linear-gradient(90deg, var(--accent), var(--accent-2));
            -webkit-background-clip:text; background-clip:text; padding:0 2px;
        }
        .aw .page-hero p { color:var(--text-muted,#64748b); font-size:.95rem; margin:0; max-width:540px; }
        .aw .hero-line {
            position:absolute; bottom:0; left:0; right:0; height:3px;
            background:linear-gradient(90deg, var(--accent), var(--accent-2), transparent);
        }

        /* ── SUMMARY STATS ──────────────────────────────────── */
        .aw .stats-row { display:grid; grid-template-columns:repeat(3,1fr); gap:14px; margin-bottom:28px; }
        @media(max-width:768px){ .aw .stats-row { grid-template-columns:repeat(2,1fr); } }
        @media(max-width:480px){ .aw .stats-row { grid-template-columns:1fr; } }
        .aw .stat-card {
            background:var(--bg-card,#fff); border:1.5px solid var(--border-color,#e2e8f0);
            border-radius:16px; padding:18px 20px;
            display:flex; align-items:center; gap:14px;
            transition:transform .2s ease, box-shadow .2s ease;
        }
        .aw .stat-card:hover { transform:translateY(-3px); box-shadow:0 8px 22px rgba(0,0,0,.07); }
        .aw .stat-icon {
            width:46px; height:46px; border-radius:13px; flex-shrink:0;
            display:grid; place-items:center; font-size:1.1rem;
        }
        .aw .si-blue   { background:rgba(14,165,233,.12); color:#0ea5e9; }
        .aw .si-teal   { background:rgba(13,148,136,.12); color:#0d9488; }
        .aw .si-amber  { background:rgba(217,119,6,.12);  color:#d97706; }
        .aw .si-rose   { background:rgba(239,68,68,.12);  color:#ef4444; }
        .aw .stat-info h3 { font-family:'Outfit',sans-serif; font-size:1.55rem; font-weight:800; color:var(--text-main,#0f172a); margin:0 0 1px; line-height:1; }
        .aw .stat-info span { font-size:.78rem; color:var(--text-muted,#64748b); font-weight:500; }

        /* ── FILTER TABS ────────────────────────────────────── */
        .aw .filter-tabs { display:flex; gap:8px; flex-wrap:wrap; margin-bottom:26px; }
        .aw .filter-tab {
            font-family:'Outfit',sans-serif; font-size:.82rem; font-weight:600;
            padding:8px 18px; border-radius:50px; border:1.5px solid var(--border-color,#e2e8f0);
            background:var(--bg-card,#fff); color:var(--text-muted,#64748b);
            cursor:pointer; transition:all .18s; display:flex; align-items:center; gap:7px;
        }
        .aw .filter-tab:hover { border-color:var(--accent); color:var(--accent); }
        .aw .filter-tab.active { background:var(--accent); border-color:var(--accent); color:#fff; box-shadow:0 4px 14px var(--accent-glow); }

        /* ── SECTION HEADER ─────────────────────────────────── */
        .aw .section-hdr { display:flex; align-items:center; gap:14px; margin-bottom:16px; }
        .aw .sec-badge {
            width:38px; height:38px; border-radius:11px; flex-shrink:0;
            display:grid; place-items:center; font-size:.9rem;
        }
        .aw .sec-badge.ml    { background:linear-gradient(135deg,#0d9488,#0891b2); color:#fff; }
        .aw .sec-badge.robot { background:linear-gradient(135deg,#7c3aed,#6366f1); color:#fff; }
        .aw .section-hdr h3 { font-family:'Outfit',sans-serif; font-size:1rem; font-weight:700; color:var(--text-main,#0f172a); margin:0; }
        .aw .section-hdr .divider { flex:1; height:1px; background:var(--border-color,#e2e8f0); margin-left:10px; }

        /* ── CARD GRID ──────────────────────────────────────── */
        .aw .card-grid { display:grid; grid-template-columns:repeat(auto-fill,minmax(230px,1fr)); gap:18px; margin-bottom:32px; }

        /* ── COURSE CARD ────────────────────────────────────── */
        .aw .course-card {
            background:var(--bg-card,#fff); border:1.5px solid var(--border-color,#e2e8f0);
            border-radius:16px; overflow:hidden; position:relative;
            transition:transform .2s ease, box-shadow .2s ease, border-color .2s ease;
        }
        .aw .course-card:hover { transform:translateY(-3px); box-shadow:0 10px 28px rgba(217,119,6,.14); border-color:var(--accent); }

        .aw .status-badge {
            position:absolute; top:10px; right:10px; z-index:2;
            font-family:'Outfit',sans-serif; font-size:.65rem; font-weight:700;
            letter-spacing:.05em; text-transform:uppercase;
            padding:3px 9px; border-radius:20px;
        }
        .aw .badge-published   { background:rgba(13,148,136,.15); color:#0d9488; }
        .aw .badge-draft       { background:rgba(100,116,139,.12); color:#64748b; }
        .aw .badge-unpublished { background:rgba(239,68,68,.12); color:#dc2626; }

        .aw .card-banner { height:100px; display:grid; place-items:center; overflow:hidden; }
        .aw .card-banner.bml   { background:linear-gradient(135deg,#ccfbf1,#cffafe); }
        .aw .card-banner.brobot{ background:linear-gradient(135deg,#ede9fe,#e0e7ff); }
        [data-theme="dark"] .aw .card-banner.bml   { background:linear-gradient(135deg,#064e3b,#065f46); }
        [data-theme="dark"] .aw .card-banner.brobot{ background:linear-gradient(135deg,#2e1065,#1e1b4b); }
        .aw .card-banner i { font-size:2rem; opacity:.7; }
        .aw .card-banner.bml i   { color:#0d9488; }
        .aw .card-banner.brobot i{ color:#7c3aed; }
        [data-theme="dark"] .aw .card-banner.bml i   { color:#34d399; }
        [data-theme="dark"] .aw .card-banner.brobot i{ color:#a78bfa; }

        .aw .card-body  { padding:14px 16px 16px; }
        .aw .card-title { font-family:'Outfit',sans-serif; font-size:.9rem; font-weight:700; color:var(--text-main,#0f172a); margin-bottom:10px; line-height:1.3; }

        /* ── MINI STATS ─────────────────────────────────────── */
        .aw .mini-stats { display:flex; gap:8px; margin-bottom:12px; }
        .aw .mini-stat {
            flex:1; background:var(--bg-sidebar,#f8fafc); border:1px solid var(--border-color,#e2e8f0);
            border-radius:9px; padding:7px 6px; text-align:center;
        }
        .aw .mini-stat .val { display:block; font-family:'Outfit',sans-serif; font-size:.92rem; font-weight:800; color:var(--text-main,#0f172a); }
        .aw .mini-stat .lbl { display:block; font-size:.65rem; color:var(--text-muted,#64748b); font-weight:500; }

        /* ── PROGRESS BAR ───────────────────────────────────── */
        .aw .prog-wrap { margin-bottom:12px; }
        .aw .prog-labels { display:flex; justify-content:space-between; font-size:.73rem; color:var(--text-muted,#64748b); margin-bottom:4px; }
        .aw .prog-bg { height:5px; background:var(--border-color,#e2e8f0); border-radius:6px; overflow:hidden; }
        .aw .prog-fill { height:100%; border-radius:6px; background:linear-gradient(90deg,var(--accent),var(--accent-2)); transition:width .5s ease; }

        /* ── VIEW ANALYTICS BUTTON ──────────────────────────── */
        .aw .btn-view {
            display:flex; align-items:center; justify-content:center; gap:6px; width:100%;
            font-family:'Outfit',sans-serif; font-size:.82rem; font-weight:700;
            padding:9px; border-radius:9px;
            background:linear-gradient(135deg,var(--accent),var(--accent-2));
            color:#fff; border:none; cursor:pointer; text-decoration:none;
            box-shadow:0 4px 12px var(--accent-glow); transition:opacity .18s;
        }
        .aw .btn-view:hover { opacity:.88; color:#fff; text-decoration:none; }

        /* ── BACK BUTTON ────────────────────────────────────── */
        .aw .btn-back {
            display:inline-flex; align-items:center; gap:7px;
            font-family:'Outfit',sans-serif; font-size:.84rem; font-weight:600;
            padding:8px 18px; border-radius:50px; border:1.5px solid var(--border-color,#e2e8f0);
            background:var(--bg-card,#fff); color:var(--text-main,#0f172a);
            cursor:pointer; text-decoration:none; transition:all .18s; margin-bottom:22px;
        }
        .aw .btn-back:hover { border-color:var(--accent); color:var(--accent); text-decoration:none; }

        /* ── ANALYTICS PANEL ────────────────────────────────── */
        .aw .analytics-panel {
            background:var(--bg-card,#fff); border:1.5px solid var(--border-color,#e2e8f0);
            border-radius:20px; padding:28px 32px;
        }
        .aw .analytics-panel h2 {
            font-family:'Outfit',sans-serif; font-size:1.35rem; font-weight:800;
            color:var(--text-main,#0f172a); margin:0 0 22px;
            display:flex; align-items:center; gap:10px;
        }
        .aw .analytics-panel h2 i { color:var(--accent); }

        /* ── KPI CARDS ──────────────────────────────────────── */
        .aw .kpi-grid { display:grid; grid-template-columns:repeat(3,1fr); gap:14px; margin-bottom:22px; }
        @media(max-width:600px){ .aw .kpi-grid { grid-template-columns:1fr; } }
        .aw .kpi-card {
            border-radius:14px; padding:18px 20px; text-align:center;
            border:1.5px solid var(--border-color,#e2e8f0);
        }
        .aw .kpi-card.kpi-blue   { background:rgba(14,165,233,.06); border-color:rgba(14,165,233,.2); }
        .aw .kpi-card.kpi-teal   { background:rgba(13,148,136,.06); border-color:rgba(13,148,136,.2); }
        .aw .kpi-card.kpi-amber  { background:rgba(217,119,6,.06);  border-color:rgba(217,119,6,.2); }
        .aw .kpi-card h3 {
            font-family:'Outfit',sans-serif; font-size:2rem; font-weight:800; margin:0 0 4px; line-height:1;
        }
        .aw .kpi-card.kpi-blue h3  { color:#0ea5e9; }
        .aw .kpi-card.kpi-teal h3  { color:#0d9488; }
        .aw .kpi-card.kpi-amber h3 { color:#d97706; }
        .aw .kpi-card span { font-size:.8rem; color:var(--text-muted,#64748b); display:flex; align-items:center; justify-content:center; gap:5px; }

        /* ── DETAILS BOX ────────────────────────────────────── */
        .aw .detail-box {
            background:var(--bg-sidebar,#f8fafc); border:1px solid var(--border-color,#e2e8f0);
            border-radius:12px; padding:16px 20px; margin-bottom:24px;
            display:grid; grid-template-columns:repeat(3,1fr); gap:14px;
        }
        @media(max-width:600px){ .aw .detail-box { grid-template-columns:1fr; } }
        .aw .detail-item small {
            display:block; font-family:'Outfit',sans-serif; font-size:.7rem; font-weight:700;
            color:var(--text-muted,#64748b); text-transform:uppercase; letter-spacing:.06em; margin-bottom:3px;
        }
        .aw .detail-item p { margin:0; font-weight:700; font-size:.9rem; color:var(--text-main,#0f172a); }

        /* ── COMPLETIONS TABLE ──────────────────────────────── */
        .aw .comp-table-hdr {
            font-family:'Outfit',sans-serif; font-size:.95rem; font-weight:700;
            color:var(--text-main,#0f172a); margin-bottom:14px;
            display:flex; align-items:center; gap:7px;
        }
        .aw .comp-table-hdr i { color:var(--accent); }
        .aw .completions-table { width:100%; border-collapse:collapse; font-size:.85rem; }
        .aw .completions-table thead tr { background:rgba(217,119,6,.08); }
        .aw .completions-table th {
            font-family:'Outfit',sans-serif; font-size:.75rem; font-weight:700;
            color:var(--text-main,#0f172a); text-align:left; padding:10px 14px;
            border-bottom:2px solid var(--border-color,#e2e8f0); text-transform:uppercase; letter-spacing:.04em;
        }
        .aw .completions-table td { padding:10px 14px; border-bottom:1px solid var(--border-color,#e2e8f0); color:var(--text-main,#0f172a); }
        .aw .completions-table tbody tr:hover { background:var(--bg-sidebar,#f8fafc); }
        .aw .no-data { text-align:center; padding:32px; color:var(--text-muted,#64748b); font-size:.88rem; }

        /* ── ALERT ──────────────────────────────────────────── */
        .aw .alert-box {
            display:block; padding:12px 18px; border-radius:10px; margin-bottom:18px;
            font-size:.88rem; font-weight:500;
        }
        .aw .alert-success { background:rgba(13,148,136,.1); color:#0d9488; border:1px solid rgba(13,148,136,.2); }
    </style>
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
<div class="aw">
    <asp:MultiView ID="MainMultiView" runat="server" ActiveViewIndex="0">

        <%-- ════════════════════ VIEW 0: DASHBOARD ════════════════════ --%>
        <asp:View ID="ViewDashboard" runat="server">

            <div class="page-hero">
                <div class="hero-eyebrow"><i class="fas fa-chart-bar"></i> Admin Panel</div>
                <h1>Course <mark>Administration</mark></h1>
                <p>Monitor learning material status and student enrollment statistics across all modules.</p>
                <div class="hero-line"></div>
            </div>

            <asp:Label ID="lblMessage" runat="server" Visible="false" CssClass="alert-box alert-success"></asp:Label>

            <%-- Summary Stats from DB --%>
            <div class="stats-row">
                <div class="stat-card">
                    <div class="stat-icon si-blue"><i class="fas fa-book-open"></i></div>
                    <div class="stat-info">
                        <h3><asp:Label ID="lblTotalArticles" runat="server">0</asp:Label></h3>
                        <span>Total Articles</span>
                    </div>
                </div>
                <div class="stat-card">
                    <div class="stat-icon si-teal"><i class="fas fa-check-circle"></i></div>
                    <div class="stat-info">
                        <h3><asp:Label ID="lblPublished" runat="server">0</asp:Label></h3>
                        <span>Published</span>
                    </div>
                </div>
                <div class="stat-card">
                    <div class="stat-icon si-amber"><i class="fas fa-user-graduate"></i></div>
                    <div class="stat-info">
                        <h3><asp:Label ID="lblTotalCompletions" runat="server">0</asp:Label></h3>
                        <span>Total Completions</span>
                    </div>
                </div>
                <div class="stat-card">
                    <div class="stat-icon si-rose"><i class="fas fa-users"></i></div>
                    <div class="stat-info">
                        <h3><asp:Label ID="lblTotalMembers" runat="server">0</asp:Label></h3>
                        <span>Registered Members</span>
                    </div>
                </div>
            </div>

            <%-- Filter Tabs --%>
            <div class="filter-tabs">
                <button type="button" class="filter-tab active" data-filter="all"   onclick="filterSec('all',this)"><i class="fas fa-th"></i> All</button>
                <button type="button" class="filter-tab"        data-filter="ml"    onclick="filterSec('ml',this)"><i class="fas fa-brain"></i> Machine Learning</button>
                <button type="button" class="filter-tab"        data-filter="robot" onclick="filterSec('robot',this)"><i class="fas fa-microchip"></i> Robotics</button>
            </div>

            <%-- Machine Learning --%>
            <div id="sec-ml" class="mb-4">
                <div class="section-hdr">
                    <div class="sec-badge ml"><i class="fas fa-brain"></i></div>
                    <h3>Machine Learning</h3>
                    <div class="divider"></div>
                </div>
                <div class="card-grid">
                    <asp:Repeater ID="rptML" runat="server" OnItemCommand="rptCourses_ItemCommand">
                        <ItemTemplate>
                            <div class="course-card">
                                <div class="card-banner bml">
                                    <i class="fas <%# Eval("ImageURL") %>"></i>
                                </div>
                                <div class="card-body">
                                    <div class="card-title"><%# Eval("Title") %></div>
                                    <div class="mini-stats">
                                        <div class="mini-stat"><span class="val"><%# Eval("Views") %></span><span class="lbl">Views</span></div>
                                        <div class="mini-stat"><span class="val"><%# Eval("Completions") %></span><span class="lbl">Done</span></div>
                                        <div class="mini-stat"><span class="val"><%# Eval("QuestionCount") %></span><span class="lbl">Qs</span></div>
                                    </div>
                                    <div class="prog-wrap">
                                        <div class="prog-labels"><span>Completion Rate</span><span><%# Eval("CompletionRate") %>%</span></div>
                                        <div class="prog-bg"><div class="prog-fill" style='<%# "width:" + Eval("CompletionRate") + "%" %>'></div></div>
                                    </div>
                                    <asp:LinkButton runat="server" CommandName="ViewArticle" CommandArgument='<%# Eval("ArticleID") %>' CssClass="btn-view">
                                        <i class="fas fa-chart-bar"></i> View Analytics
                                    </asp:LinkButton>
                                </div>
                            </div>
                        </ItemTemplate>
                    </asp:Repeater>
                </div>
            </div>

            <%-- Robotics --%>
            <div id="sec-robot">
                <div class="section-hdr">
                    <div class="sec-badge robot"><i class="fas fa-microchip"></i></div>
                    <h3>Robotics</h3>
                    <div class="divider"></div>
                </div>
                <div class="card-grid">
                    <asp:Repeater ID="rptRobot" runat="server" OnItemCommand="rptCourses_ItemCommand">
                        <ItemTemplate>
                            <div class="course-card">
                                <div class="card-banner brobot">
                                    <i class="fas <%# Eval("ImageURL") %>"></i>
                                </div>
                                <div class="card-body">
                                    <div class="card-title"><%# Eval("Title") %></div>
                                    <div class="mini-stats">
                                        <div class="mini-stat"><span class="val"><%# Eval("Views") %></span><span class="lbl">Views</span></div>
                                        <div class="mini-stat"><span class="val"><%# Eval("Completions") %></span><span class="lbl">Done</span></div>
                                        <div class="mini-stat"><span class="val"><%# Eval("QuestionCount") %></span><span class="lbl">Qs</span></div>
                                    </div>
                                    <div class="prog-wrap">
                                        <div class="prog-labels"><span>Completion Rate</span><span><%# Eval("CompletionRate") %>%</span></div>
                                        <div class="prog-bg"><div class="prog-fill" style='<%# "width:" + Eval("CompletionRate") + "%" %>'></div></div>
                                    </div>
                                    <asp:LinkButton runat="server" CommandName="ViewArticle" CommandArgument='<%# Eval("ArticleID") %>' CssClass="btn-view">
                                        <i class="fas fa-chart-bar"></i> View Analytics
                                    </asp:LinkButton>
                                </div>
                            </div>
                        </ItemTemplate>
                    </asp:Repeater>
                </div>
            </div>

        </asp:View>

        <%-- ════════════════════ VIEW 1: ANALYTICS ════════════════════ --%>
        <asp:View ID="ViewAnalytics" runat="server">

            <asp:LinkButton ID="btnBack" runat="server" OnClick="btnBack_Click" CssClass="btn-back">
                <i class="fas fa-arrow-left"></i> Back to Dashboard
            </asp:LinkButton>

            <div class="analytics-panel">
                <h2>
                    <i class="fas fa-chart-bar"></i>
                    <asp:Label ID="lblAnalyticsTitle" runat="server"></asp:Label>
                </h2>

                <%-- KPI Cards --%>
                <div class="kpi-grid">
                    <div class="kpi-card kpi-blue">
                        <h3><asp:Label ID="lblTotalViews" runat="server">0</asp:Label></h3>
                        <span><i class="fas fa-eye"></i> Total Views</span>
                    </div>
                    <div class="kpi-card kpi-teal">
                        <h3><asp:Label ID="lblStudentCompletions" runat="server">0</asp:Label></h3>
                        <span><i class="fas fa-user-graduate"></i> Students Completed</span>
                    </div>
                    <div class="kpi-card kpi-amber">
                        <h3><asp:Label ID="lblCompletionRate" runat="server">0</asp:Label>%</h3>
                        <span><i class="fas fa-trophy"></i> Completion Rate</span>
                    </div>
                </div>

                <%-- Article Details --%>
                <div class="detail-box">
                    <div class="detail-item">
                        <small>Category</small>
                        <p><asp:Label ID="lblCategory" runat="server"></asp:Label></p>
                    </div>
                    <div class="detail-item">
                        <small>Quiz Questions</small>
                        <p><asp:Label ID="lblQCount" runat="server">0</asp:Label> questions</p>
                    </div>
                </div>

                <%-- Who Completed --%>
                <div class="comp-table-hdr">
                    <i class="fas fa-users"></i> Students Who Completed This Module
                </div>
                <asp:Literal ID="litCompletions" runat="server"></asp:Literal>
            </div>

        </asp:View>

    </asp:MultiView>
</div>

<script>
    function filterSec(cat, btn) {
        localStorage.setItem('adminCourseFilter', cat);
        var ml = document.getElementById('sec-ml');
        var robot = document.getElementById('sec-robot');
        if (ml) ml.style.display = (cat === 'robot') ? 'none' : '';
        if (robot) robot.style.display = (cat === 'ml') ? 'none' : '';
        document.querySelectorAll('.filter-tab').forEach(function (b) { b.classList.remove('active'); });
        btn.classList.add('active');
    }
    window.addEventListener('DOMContentLoaded', function () {
        var saved = localStorage.getItem('adminCourseFilter') || 'all';
        var ml = document.getElementById('sec-ml');
        var robot = document.getElementById('sec-robot');
        if (ml) ml.style.display = (saved === 'robot') ? 'none' : '';
        if (robot) robot.style.display = (saved === 'ml') ? 'none' : '';
        document.querySelectorAll('.filter-tab').forEach(function (b) {
            b.classList.remove('active');
            if (b.getAttribute('data-filter') === saved) b.classList.add('active');
        });
    });
</script>
</asp:Content>