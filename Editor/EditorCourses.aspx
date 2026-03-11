<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="EditorCourses.aspx.cs" Inherits="Zero_to_AI.Editor.EditorCourses" ValidateRequest="false" %>
<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
<link href="https://fonts.googleapis.com/css2?family=Syne:wght@600;700;800&family=DM+Sans:opsz,wght@9..40,400;9..40,500;9..40,600&display=swap" rel="stylesheet">
<style>
/*──────────────────────────────────────────────────────────
  EDITORCOURSES.ASPX — Editor Dashboard
  IMPORTANT: ValidateRequest="false" in @Page directive is
             required so editors can save HTML in txtContent.
  Accent: Violet #7c3aed
  All bg/text via Site.Master vars — light/dark auto-works.
──────────────────────────────────────────────────────────*/
.edt {
  --vio:   #7c3aed; --vio-l:   rgba(124,58,237,.1);  --vio-b:   rgba(124,58,237,.3);
  --teal:  #0d9488; --teal-l:  rgba(13,148,136,.1);  --teal-b:  rgba(13,148,136,.3);
  --sky:   #0ea5e9; --sky-l:   rgba(14,165,233,.1);  --sky-b:   rgba(14,165,233,.3);
  --rose:  #e11d48; --rose-l:  rgba(225,29,72,.08);  --rose-b:  rgba(225,29,72,.28);
  --amber: #d97706; --amber-l: rgba(217,119,6,.1);   --amber-b: rgba(217,119,6,.3);
  font-family: 'DM Sans', sans-serif;
}
/* HERO */
.edt-hero { padding:46px 36px 42px; background:var(--bg-card,#f8fafc);
  border-bottom:1px solid var(--border-color,#e2e8f0); position:relative; overflow:hidden; }
.edt-hero::after { content:''; position:absolute; bottom:0; left:36px; right:36px; height:2px;
  background:linear-gradient(90deg,var(--vio),var(--teal),transparent); border-radius:99px; }
.hero-pill { display:inline-flex; align-items:center; gap:7px; padding:5px 14px; border-radius:99px;
  margin-bottom:16px; background:var(--vio-l); border:1px solid var(--vio-b);
  font-family:'Syne',sans-serif; font-size:.68rem; font-weight:700; letter-spacing:.12em;
  text-transform:uppercase; color:var(--vio); }
.edt-hero h1 { font-family:'Syne',sans-serif; font-size:clamp(1.75rem,3.5vw,2.5rem);
  font-weight:800; color:var(--text-main,#0f172a); line-height:1.15; margin:0 0 10px; letter-spacing:-.025em; }
.edt-hero h1 mark { background:none; color:var(--vio); border-bottom:3px solid var(--vio); }
.edt-hero p { font-size:.96rem; color:var(--text-muted,#64748b); margin:0; max-width:460px; line-height:1.65; }

/* ALERTS — all 3 variants used by the CS file */
.alert-box { display:block; margin:14px 36px 0; padding:11px 16px; border-radius:10px;
  font-size:.87rem; border:1px solid; }
.alert-success { background:rgba(13,148,136,.1);  border-color:rgba(13,148,136,.3);  color:#0d9488; }
.alert-danger  { background:rgba(225,29,72,.08);  border-color:rgba(225,29,72,.28);  color:#e11d48; }
.alert-info    { background:var(--vio-l);           border-color:var(--vio-b);          color:var(--vio); }

/* TOOLBAR */
.toolbar { display:flex; align-items:center; justify-content:space-between;
  flex-wrap:wrap; gap:12px; padding:22px 36px 0; }
.filter-tabs { display:flex; gap:8px; flex-wrap:wrap; }
.filter-tab { display:inline-flex; align-items:center; gap:7px; padding:8px 16px; border-radius:8px;
  border:1px solid var(--border-color,#e2e8f0); background:transparent;
  color:var(--text-muted,#64748b); font-family:'DM Sans',sans-serif;
  font-size:.85rem; font-weight:500; cursor:pointer; transition:all .2s; }
.filter-tab:hover  { border-color:var(--vio-b); color:var(--vio); background:var(--vio-l); }
.filter-tab.active { background:var(--vio); border-color:var(--vio); color:#fff; font-weight:600; }
.btn-add-new { display:inline-flex; align-items:center; gap:8px; padding:9px 20px; border-radius:8px;
  background:var(--vio); color:#fff; border:none; cursor:pointer;
  font-family:'Syne',sans-serif; font-size:.84rem; font-weight:700; white-space:nowrap; transition:all .2s; }
.btn-add-new:hover { background:#6d28d9; color:#fff; text-decoration:none; box-shadow:0 4px 14px rgba(124,58,237,.3); }

/* SECTIONS */
.sec-block { padding:26px 36px 0; }
.sec-hdr { display:flex; align-items:center; gap:12px; margin-bottom:16px; }
.sec-icon { width:40px; height:40px; border-radius:10px; flex-shrink:0;
  display:flex; align-items:center; justify-content:center; font-size:.95rem; }
.sec-icon.ml    { background:var(--teal-l); color:var(--teal); border:1px solid var(--teal-b); }
.sec-icon.robot { background:var(--sky-l);  color:var(--sky);  border:1px solid var(--sky-b); }
.sec-hdr h3 { font-family:'Syne',sans-serif; font-size:.97rem; font-weight:700; color:var(--text-main,#0f172a); margin:0; }
.sec-div    { flex:1; height:1px; background:var(--border-color,#e2e8f0); }

/* CARD GRID */
.row { display:flex; flex-wrap:wrap; margin:0 -9px; }
.row.g-3>* { padding:0 9px 18px; }
.col-12 { width:100%; }
@media(min-width:576px){ .col-sm-6 { width:50%; } }
@media(min-width:992px){ .col-lg-3 { width:25%; } }

/* EDITOR CARD */
.course-card { position:relative; background:var(--bg-card,#fff);
  border:1px solid var(--border-color,#e2e8f0); border-radius:14px; overflow:hidden;
  display:flex; flex-direction:column; height:100%;
  transition:transform .22s,box-shadow .22s,border-color .22s; }
.course-card:hover { transform:translateY(-4px); border-color:var(--vio-b); box-shadow:0 12px 32px rgba(0,0,0,.1); }

.status-badge { position:absolute; top:10px; left:10px; z-index:2;
  font-family:'Syne',sans-serif; font-size:.61rem; font-weight:700;
  letter-spacing:.08em; text-transform:uppercase; padding:3px 10px; border-radius:99px; }
.badge-published   { background:rgba(13,148,136,.1);  color:#0d9488; border:1px solid rgba(13,148,136,.3); }
.badge-draft       { background:rgba(217,119,6,.1);   color:#d97706; border:1px solid rgba(217,119,6,.3); }
.badge-unpublished { background:rgba(225,29,72,.08);  color:#e11d48; border:1px solid rgba(225,29,72,.28); }

.card-banner { height:114px; display:flex; align-items:center; justify-content:center; font-size:2.2rem; }
.banner-ml    { background:linear-gradient(135deg,#ecfdf5,#d1fae5,#a7f3d0); color:#0d9488; }
.banner-robot { background:linear-gradient(135deg,#e0f2fe,#bae6fd,#93c5fd); color:#0ea5e9; }
[data-theme="dark"] .banner-ml    { background:linear-gradient(135deg,#064e3b,#065f46); }
[data-theme="dark"] .banner-robot { background:linear-gradient(135deg,#0c2d4a,#0d3a6b); }

.card-body  { padding:14px 14px 15px; display:flex; flex-direction:column; flex:1; }
.card-title { font-family:'Syne',sans-serif; font-size:.87rem; font-weight:700;
  color:var(--text-main,#0f172a); line-height:1.35; margin-bottom:5px; }
.card-desc  { font-size:.77rem; color:var(--text-muted,#64748b); line-height:1.5; margin-bottom:12px; flex:1;
  display:-webkit-box; -webkit-line-clamp:2; -webkit-box-orient:vertical; overflow:hidden; }

.btn-grid { display:grid; grid-template-columns:1fr auto; gap:7px; margin-bottom:7px; }
.btn-edit { display:flex; align-items:center; justify-content:center; gap:6px; padding:9px;
  border-radius:8px; background:var(--vio-l); border:1px solid var(--vio-b); color:var(--vio);
  font-family:'Syne',sans-serif; font-size:.77rem; font-weight:700; cursor:pointer;
  transition:all .2s; text-decoration:none; }
.btn-edit:hover { background:var(--vio); color:#fff; text-decoration:none; }
.btn-del  { display:flex; align-items:center; justify-content:center; width:38px; border-radius:8px;
  background:var(--rose-l); border:1px solid var(--rose-b); color:#e11d48;
  cursor:pointer; font-size:.82rem; transition:all .2s; text-decoration:none; }
.btn-del:hover  { background:#e11d48; color:#fff; text-decoration:none; }
.btn-quiz { display:flex; align-items:center; justify-content:center; gap:6px; padding:9px;
  width:100%; border-radius:8px; border:1px solid var(--border-color,#e2e8f0);
  background:transparent; color:var(--text-muted,#64748b);
  font-size:.77rem; font-weight:500; cursor:pointer; transition:all .2s;
  font-family:'DM Sans',sans-serif; text-decoration:none; }
.btn-quiz:hover { border-color:var(--teal-b); color:var(--teal); background:var(--teal-l); text-decoration:none; }

/* BACK */
.btn-back { display:inline-flex; align-items:center; gap:7px; padding:8px 16px; margin:20px 36px 0;
  border-radius:8px; border:1px solid var(--border-color,#e2e8f0); background:transparent;
  color:var(--text-muted,#64748b); font-size:.84rem; text-decoration:none; cursor:pointer; transition:all .2s; }
.btn-back:hover { border-color:var(--vio-b); color:var(--vio); background:var(--vio-l); text-decoration:none; }

/* FORM PANEL */
.form-panel { margin:18px 36px 0; padding:26px 28px; background:var(--bg-card,#fff);
  border:1px solid var(--border-color,#e2e8f0); border-radius:16px; }
.form-panel h3 { font-family:'Syne',sans-serif; font-size:.97rem; font-weight:700;
  color:var(--text-main,#0f172a); margin:0 0 20px; display:flex; align-items:center; gap:9px;
  padding-bottom:14px; border-bottom:1px solid var(--border-color,#e2e8f0); }
.form-panel h3 i { color:var(--vio); }
.form-row { display:flex; gap:16px; flex-wrap:wrap; }
.form-row .form-group { flex:1; min-width:160px; }
.form-group { margin-bottom:16px; }
.form-group label { display:block; font-size:.76rem; font-weight:600;
  color:var(--text-muted,#64748b); text-transform:uppercase; letter-spacing:.07em; margin-bottom:6px; }
.form-control { width:100%; padding:10px 13px; border-radius:8px; box-sizing:border-box;
  background:var(--bg-card,#fff); border:1.5px solid var(--border-color,#e2e8f0);
  color:var(--text-main,#0f172a); font-family:'DM Sans',sans-serif; font-size:.9rem;
  transition:border-color .2s,box-shadow .2s; -webkit-appearance:none; }
.form-control:focus { outline:none; border-color:var(--vio-b); box-shadow:0 0 0 3px rgba(124,58,237,.12); }
.content-textarea { width:100%; min-height:280px; padding:13px; border-radius:8px; box-sizing:border-box;
  background:var(--bg-card,#f8fafc); border:1.5px solid var(--border-color,#e2e8f0);
  color:var(--text-main,#0f172a); font-family:'Courier New',monospace; font-size:.87rem;
  line-height:1.6; resize:vertical; transition:border-color .2s,box-shadow .2s; }
.content-textarea:focus { outline:none; border-color:var(--vio-b); box-shadow:0 0 0 3px rgba(124,58,237,.12); }
.btn-save { padding:10px 26px; border-radius:8px; background:var(--vio); color:#fff; border:none;
  cursor:pointer; font-family:'Syne',sans-serif; font-size:.86rem; font-weight:700; transition:all .2s; }
.btn-save:hover { background:#6d28d9; box-shadow:0 4px 14px rgba(124,58,237,.3); }
.d-flex { display:flex; }
.justify-content-end { justify-content:flex-end; }

/* QUIZ PANEL */
.quiz-panel { margin:18px 36px 48px; padding:24px 26px; background:var(--bg-card,#fff);
  border:1px solid var(--border-color,#e2e8f0); border-radius:16px; }
.quiz-panel h4 { font-family:'Syne',sans-serif; font-size:.96rem; font-weight:700;
  color:var(--text-main,#0f172a); margin:0 0 18px; display:flex; align-items:center; gap:9px;
  flex-wrap:wrap; padding-bottom:13px; border-bottom:1px solid var(--border-color,#e2e8f0); }
.quiz-panel h4 i { color:var(--amber); }
.q-card { border:1px solid var(--border-color,#e2e8f0); border-radius:10px; padding:14px;
  margin-bottom:10px; background:var(--bg-card,#f8fafc); }
.q-text { font-weight:600; color:var(--text-main,#0f172a); margin-bottom:9px; font-size:.88rem; line-height:1.5; }
.q-opts { display:flex; flex-wrap:wrap; gap:6px; margin-bottom:9px; }
.q-opts span { font-size:.76rem; color:var(--text-muted,#64748b); padding:4px 10px;
  border:1px solid var(--border-color,#e2e8f0); border-radius:6px; background:var(--bg-card,#fff); }
.q-opts span strong { color:var(--vio); }
.correct-badge { display:inline-block; font-family:'Syne',sans-serif; font-size:.66rem; font-weight:700;
  padding:3px 10px; border-radius:99px; margin-bottom:9px;
  background:rgba(13,148,136,.1); color:#0d9488; border:1px solid rgba(13,148,136,.3); }
.q-actions { display:flex; gap:7px; }
.btn-q-edit { display:inline-flex; align-items:center; gap:5px; padding:6px 12px; border-radius:7px;
  font-size:.76rem; font-weight:600; background:var(--vio-l); border:1px solid var(--vio-b);
  color:var(--vio); cursor:pointer; transition:all .18s; text-decoration:none; }
.btn-q-edit:hover { background:var(--vio); color:#fff; text-decoration:none; }
.btn-q-del  { display:inline-flex; align-items:center; gap:5px; padding:6px 12px; border-radius:7px;
  font-size:.76rem; font-weight:600; background:var(--rose-l); border:1px solid var(--rose-b);
  color:#e11d48; cursor:pointer; transition:all .18s; text-decoration:none; }
.btn-q-del:hover  { background:#e11d48; color:#fff; text-decoration:none; }
.no-quiz-msg { text-align:center; color:var(--text-muted,#94a3b8); padding:16px 0; font-size:.86rem; }
.no-quiz-msg i { display:block; font-size:1.3rem; margin-bottom:6px; }
.add-q-form { margin-top:20px; padding:20px; background:var(--vio-l); border:1px solid var(--vio-b); border-radius:12px; }
.add-q-form h5 { font-family:'Syne',sans-serif; font-size:.87rem; font-weight:700;
  color:var(--text-main,#0f172a); margin:0 0 15px; display:flex; align-items:center; gap:7px; }
.add-q-form h5 i { color:var(--vio); }
.opts-grid { display:grid; grid-template-columns:1fr 1fr; gap:12px; }
@media(max-width:560px){ .opts-grid { grid-template-columns:1fr; } }
.btn-add-q { padding:9px 22px; border-radius:8px; background:var(--vio); color:#fff; border:none;
  cursor:pointer; font-family:'Syne',sans-serif; font-size:.85rem; font-weight:700; margin-top:6px; transition:all .2s; }
.btn-add-q:hover { background:#6d28d9; }

/* Responsive */
@media(max-width:768px){
  .edt-hero { padding-left:18px; padding-right:18px; }
  .edt-hero::after { left:18px; right:18px; }
  .toolbar,.sec-block { padding-left:18px; padding-right:18px; }
  .btn-back { margin-left:18px; margin-right:18px; }
  .form-panel,.quiz-panel { margin-left:18px; margin-right:18px; }
  .alert-box { margin-left:18px; margin-right:18px; }
}
</style>
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
<div class="edt">
<asp:MultiView ID="MainMultiView" runat="server" ActiveViewIndex="0">

  <%-- ════════ VIEW 0 : DASHBOARD ════════ --%>
  <asp:View ID="ViewDashboard" runat="server">
    <div class="edt-hero">
      <div class="hero-pill"><i class="fas fa-edit"></i> Content Editor</div>
      <h1>Manage <mark>Content</mark></h1>
      <p>Edit articles, manage quiz questions, and control content visibility for all learners.</p>
    </div>

    <asp:Label ID="lblMessage" runat="server" Visible="false" CssClass="alert-box"></asp:Label>

    <div class="toolbar">
      <div class="filter-tabs">
        <button class="filter-tab active" data-filter="all"   onclick="filterSec('all',this)"><i class="fas fa-th-large"></i> All</button>
        <button class="filter-tab"        data-filter="ml"   onclick="filterSec('ml',this)"><i class="fas fa-brain"></i> Machine Learning</button>
        <button class="filter-tab"        data-filter="robot" onclick="filterSec('robot',this)"><i class="fas fa-microchip"></i> Robotics</button>
      </div>
      <asp:LinkButton ID="btnAddNew" runat="server" CssClass="btn-add-new" OnClick="btnAddNew_Click">
        <i class="fas fa-plus"></i> Add New Article
      </asp:LinkButton>
    </div>

    <div id="sec-ml" class="sec-block" style="margin-bottom:8px">
      <div class="sec-hdr">
        <div class="sec-icon ml"><i class="fas fa-brain"></i></div>
        <h3>Machine Learning</h3>
        <div class="sec-div"></div>
      </div>
      <div class="row g-3">
        <asp:Repeater ID="rptML" runat="server" OnItemCommand="rptCourses_ItemCommand">
          <ItemTemplate>
            <div class="col-12 col-sm-6 col-lg-3">
              <div class="course-card">
                <span class='status-badge <%# GetBadgeClass(Eval("Status")) %>'><%# Eval("Status") %></span>
                <div class="card-banner banner-ml"><i class="fas <%# Eval("ImageURL") %>"></i></div>
                <div class="card-body">
                  <div class="card-title"><%# Eval("Title") %></div>
                  <div class="card-desc"><%# Eval("Description") %></div>
                  <div class="btn-grid">
                    <asp:LinkButton runat="server" CommandName="EditArticle"   CommandArgument='<%# Eval("ArticleID") %>' CssClass="btn-edit"><i class="fas fa-pen"></i> Edit</asp:LinkButton>
                    <asp:LinkButton runat="server" CommandName="DeleteArticle" CommandArgument='<%# Eval("ArticleID") %>' CssClass="btn-del" OnClientClick="return confirm('Delete this article?');"><i class="fas fa-trash"></i></asp:LinkButton>
                  </div>
                  <asp:LinkButton runat="server" CommandName="ManageQuiz" CommandArgument='<%# Eval("ArticleID") %>' CssClass="btn-quiz"><i class="fas fa-question-circle"></i> Manage Quiz Questions</asp:LinkButton>
                </div>
              </div>
            </div>
          </ItemTemplate>
        </asp:Repeater>
      </div>
    </div>

    <div id="sec-robot" class="sec-block" style="padding-bottom:48px">
      <div class="sec-hdr">
        <div class="sec-icon robot"><i class="fas fa-microchip"></i></div>
        <h3>Robotics</h3>
        <div class="sec-div"></div>
      </div>
      <div class="row g-3">
        <asp:Repeater ID="rptRobot" runat="server" OnItemCommand="rptCourses_ItemCommand">
          <ItemTemplate>
            <div class="col-12 col-sm-6 col-lg-3">
              <div class="course-card">
                <span class='status-badge <%# GetBadgeClass(Eval("Status")) %>'><%# Eval("Status") %></span>
                <div class="card-banner banner-robot"><i class="fas <%# Eval("ImageURL") %>"></i></div>
                <div class="card-body">
                  <div class="card-title"><%# Eval("Title") %></div>
                  <div class="card-desc"><%# Eval("Description") %></div>
                  <div class="btn-grid">
                    <asp:LinkButton runat="server" CommandName="EditArticle"   CommandArgument='<%# Eval("ArticleID") %>' CssClass="btn-edit"><i class="fas fa-pen"></i> Edit</asp:LinkButton>
                    <asp:LinkButton runat="server" CommandName="DeleteArticle" CommandArgument='<%# Eval("ArticleID") %>' CssClass="btn-del" OnClientClick="return confirm('Delete this article?');"><i class="fas fa-trash"></i></asp:LinkButton>
                  </div>
                  <asp:LinkButton runat="server" CommandName="ManageQuiz" CommandArgument='<%# Eval("ArticleID") %>' CssClass="btn-quiz"><i class="fas fa-question-circle"></i> Manage Quiz Questions</asp:LinkButton>
                </div>
              </div>
            </div>
          </ItemTemplate>
        </asp:Repeater>
      </div>
    </div>
  </asp:View>

  <%-- ════════ VIEW 1 : EDIT ARTICLE ════════ --%>
  <asp:View ID="ViewEditArticle" runat="server">
    <asp:LinkButton ID="btnBackFromEdit" runat="server" OnClick="btnBack_Click" CssClass="btn-back" CausesValidation="false">
      <i class="fas fa-arrow-left"></i> Back
    </asp:LinkButton>
    <asp:Label ID="lblEditMsg" runat="server" Visible="false" CssClass="alert-box"></asp:Label>

    <div class="form-panel">
      <h3><i class="fas fa-edit"></i> <asp:Label ID="lblFormTitle" runat="server" Text="Edit Article"></asp:Label></h3>
      <asp:HiddenField ID="hfArticleID" runat="server" />

      <div class="form-row">
        <div class="form-group" style="flex:2;min-width:200px">
          <label>Article Title</label>
          <asp:TextBox ID="txtTitle" runat="server" CssClass="form-control" placeholder="e.g., 1. Intro to AI Concepts"></asp:TextBox>
          <asp:RequiredFieldValidator runat="server" ControlToValidate="txtTitle" ErrorMessage="Title is required." ForeColor="Red" Display="Dynamic" ValidationGroup="ArticleForm" />
        </div>
        <div class="form-group" style="min-width:130px">
          <label>Status</label>
          <asp:DropDownList ID="ddlStatus" runat="server" CssClass="form-control">
            <asp:ListItem Text="Published"   Value="Published"></asp:ListItem>
            <asp:ListItem Text="Draft"       Value="Draft"></asp:ListItem>
            <asp:ListItem Text="Unpublished" Value="Unpublished"></asp:ListItem>
          </asp:DropDownList>
        </div>
      </div>

      <div class="form-row">
        <div class="form-group">
          <label>Category</label>
          <asp:DropDownList ID="ddlCategory" runat="server" CssClass="form-control">
            <asp:ListItem Text="Machine Learning" Value="Machine Learning"></asp:ListItem>
            <asp:ListItem Text="Robotics"         Value="Robotics"></asp:ListItem>
          </asp:DropDownList>
        </div>
        <div class="form-group">
          <label>Icon <small style="font-weight:400;text-transform:none;letter-spacing:0">(FontAwesome e.g. fa-brain)</small></label>
          <asp:TextBox ID="txtIcon" runat="server" CssClass="form-control" placeholder="fa-brain"></asp:TextBox>
        </div>
      </div>

      <div class="form-group">
        <label>Short Description <small style="font-weight:400;text-transform:none;letter-spacing:0;color:var(--text-muted)">(use | to separate takeaways)</small></label>
        <asp:TextBox ID="txtDescription" runat="server" CssClass="form-control" TextMode="MultiLine" Rows="2" placeholder="e.g. What AI is|Key branches|Real-world applications"></asp:TextBox>
      </div>

      <div class="form-group">
        <label>Full Content <small style="font-weight:400;text-transform:none;letter-spacing:0;color:var(--text-muted)">(HTML allowed)</small></label>
        <asp:TextBox ID="txtContent" runat="server" CssClass="content-textarea" TextMode="MultiLine" placeholder="<h2>Topic</h2>&#10;<p>Start writing...</p>"></asp:TextBox>
      </div>

      <div class="d-flex justify-content-end">
        <asp:Button ID="btnSaveArticle" runat="server" Text="Save Article" CssClass="btn-save" OnClick="btnSaveArticle_Click" ValidationGroup="ArticleForm" />
      </div>
    </div>
  </asp:View>

  <%-- ════════ VIEW 2 : MANAGE QUIZ ════════ --%>
  <asp:View ID="ViewManageQuiz" runat="server">
    <asp:LinkButton ID="btnBackFromQuiz" runat="server" OnClick="btnBack_Click" CssClass="btn-back" CausesValidation="false">
      <i class="fas fa-arrow-left"></i> Back to Dashboard
    </asp:LinkButton>
    <asp:Label ID="lblQuizMsg" runat="server" Visible="false" CssClass="alert-box"></asp:Label>

    <asp:HiddenField ID="hfQuizArticleID"  runat="server" />
    <asp:HiddenField ID="hfQuizID"         runat="server" />
    <asp:HiddenField ID="hfEditQuestionID" runat="server" />

    <div class="quiz-panel">
      <h4>
        <i class="fas fa-question-circle"></i>
        Quiz Questions &mdash; <asp:Label ID="lblQuizArticleTitle" runat="server"></asp:Label>
      </h4>

      <asp:Repeater ID="rptQuestions" runat="server" OnItemCommand="rptQuestions_ItemCommand">
        <ItemTemplate>
          <div class="q-card">
            <div class="q-text"><%# Eval("QuestionText") %></div>
            <div class="q-opts">
              <span><strong>A.</strong> <%# Eval("OptionA") %></span>
              <span><strong>B.</strong> <%# Eval("OptionB") %></span>
              <span><strong>C.</strong> <%# Eval("OptionC") %></span>
              <span><strong>D.</strong> <%# Eval("OptionD") %></span>
            </div>
            <span class="correct-badge">&#10003; Answer: <%# Eval("CorrectAnswer") %></span>
            <div class="q-actions">
              <asp:LinkButton runat="server" CommandName="EditQuestion"   CommandArgument='<%# Eval("QuestionID") %>' CssClass="btn-q-edit"><i class="fas fa-pen"></i> Edit</asp:LinkButton>
              <asp:LinkButton runat="server" CommandName="DeleteQuestion" CommandArgument='<%# Eval("QuestionID") %>' CssClass="btn-q-del" OnClientClick="return confirm('Delete this question?');"><i class="fas fa-trash"></i> Delete</asp:LinkButton>
            </div>
          </div>
        </ItemTemplate>
      </asp:Repeater>

      <asp:Label ID="lblNoQuestions" runat="server" Visible="false">
        <div class="no-quiz-msg"><i class="fas fa-inbox"></i>No questions yet. Add one below.</div>
      </asp:Label>

      <div class="add-q-form">
        <h5><i class="fas fa-plus-circle"></i> <asp:Label ID="lblQFormTitle" runat="server" Text="Add New Question"></asp:Label></h5>

        <div class="form-group">
          <label>Question Text</label>
          <asp:TextBox ID="txtQText" runat="server" CssClass="form-control" TextMode="MultiLine" Rows="2" placeholder="e.g. What does AI stand for?"></asp:TextBox>
          <asp:RequiredFieldValidator runat="server" ControlToValidate="txtQText" ErrorMessage="Question text is required." ForeColor="Red" Display="Dynamic" ValidationGroup="QuizForm" />
        </div>

        <div class="opts-grid">
          <div class="form-group">
            <label>Option A</label>
            <asp:TextBox ID="txtOptA" runat="server" CssClass="form-control" placeholder="Option A"></asp:TextBox>
            <asp:RequiredFieldValidator runat="server" ControlToValidate="txtOptA" ErrorMessage="Required." ForeColor="Red" Display="Dynamic" ValidationGroup="QuizForm" />
          </div>
          <div class="form-group">
            <label>Option B</label>
            <asp:TextBox ID="txtOptB" runat="server" CssClass="form-control" placeholder="Option B"></asp:TextBox>
            <asp:RequiredFieldValidator runat="server" ControlToValidate="txtOptB" ErrorMessage="Required." ForeColor="Red" Display="Dynamic" ValidationGroup="QuizForm" />
          </div>
          <div class="form-group">
            <label>Option C</label>
            <asp:TextBox ID="txtOptC" runat="server" CssClass="form-control" placeholder="Option C"></asp:TextBox>
            <asp:RequiredFieldValidator runat="server" ControlToValidate="txtOptC" ErrorMessage="Required." ForeColor="Red" Display="Dynamic" ValidationGroup="QuizForm" />
          </div>
          <div class="form-group">
            <label>Option D</label>
            <asp:TextBox ID="txtOptD" runat="server" CssClass="form-control" placeholder="Option D"></asp:TextBox>
            <asp:RequiredFieldValidator runat="server" ControlToValidate="txtOptD" ErrorMessage="Required." ForeColor="Red" Display="Dynamic" ValidationGroup="QuizForm" />
          </div>
        </div>

        <div class="form-group">
          <label>Correct Answer</label>
          <asp:DropDownList ID="ddlCorrect" runat="server" CssClass="form-control" style="max-width:110px;">
            <asp:ListItem Text="A" Value="A"></asp:ListItem>
            <asp:ListItem Text="B" Value="B"></asp:ListItem>
            <asp:ListItem Text="C" Value="C"></asp:ListItem>
            <asp:ListItem Text="D" Value="D"></asp:ListItem>
          </asp:DropDownList>
        </div>

        <asp:Button ID="btnSaveQuestion" runat="server" CssClass="btn-add-q" OnClick="btnSaveQuestion_Click" ValidationGroup="QuizForm" Text="Save Question" />
      </div>
    </div>
  </asp:View>

</asp:MultiView>
</div>

<script>
    function filterSec(cat, btn) {
        localStorage.setItem('editorFilter', cat);
        var ml = document.getElementById('sec-ml'), rb = document.getElementById('sec-robot');
        if (ml) ml.style.display = (cat === 'robot') ? 'none' : 'block';
        if (rb) rb.style.display = (cat === 'ml') ? 'none' : 'block';
        document.querySelectorAll('.filter-tab').forEach(function (b) { b.classList.remove('active'); });
        btn.classList.add('active');
    }
    window.addEventListener('DOMContentLoaded', function () {
        var saved = localStorage.getItem('editorFilter') || 'all';
        var ml = document.getElementById('sec-ml'), rb = document.getElementById('sec-robot');
        if (ml) ml.style.display = (saved === 'robot') ? 'none' : 'block';
        if (rb) rb.style.display = (saved === 'ml') ? 'none' : 'block';
        document.querySelectorAll('.filter-tab').forEach(function (b) {
            b.classList.remove('active');
            if (b.getAttribute('data-filter') === saved) b.classList.add('active');
        });
    });
</script>
</asp:Content>