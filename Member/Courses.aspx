<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="Courses.aspx.cs" Inherits="Zero_to_AI.Member.Courses" %>
<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
<link href="https://fonts.googleapis.com/css2?family=Syne:wght@600;700;800&family=DM+Sans:opsz,wght@9..40,400;9..40,500;9..40,600&display=swap" rel="stylesheet">
<style>
/*──────────────────────────────────────────────────────────
  COURSES.ASPX — Member Learning Hub
  Accent: Teal #0d9488 + Sky #0ea5e9
  All bg/text uses Site.Master CSS variables so
  light-mode AND dark-mode toggle work automatically.
──────────────────────────────────────────────────────────*/
.crs {
  --teal:  #0d9488; --teal-l:  rgba(13,148,136,.12); --teal-b:  rgba(13,148,136,.3);
  --sky:   #0ea5e9; --sky-l:   rgba(14,165,233,.12);  --sky-b:   rgba(14,165,233,.3);
  --amber: #d97706; --amber-l: rgba(217,119,6,.12);   --amber-b: rgba(217,119,6,.3);
  --rose:  #e11d48; --rose-l:  rgba(225,29,72,.08);   --rose-b:  rgba(225,29,72,.28);
  font-family: 'DM Sans', sans-serif;
}

/* HERO */
.crs-hero { padding:46px 36px 42px; background:var(--bg-card,#f8fafc);
  border-bottom:1px solid var(--border-color,#e2e8f0); position:relative; overflow:hidden; }
.crs-hero::after { content:''; position:absolute; bottom:0; left:36px; right:36px; height:2px;
  background:linear-gradient(90deg,var(--teal),var(--sky),transparent); border-radius:99px; }
.hero-pill { display:inline-flex; align-items:center; gap:7px; padding:5px 14px; border-radius:99px;
  margin-bottom:16px; background:var(--teal-l); border:1px solid var(--teal-b);
  font-family:'Syne',sans-serif; font-size:.68rem; font-weight:700; letter-spacing:.12em;
  text-transform:uppercase; color:var(--teal); }
.crs-hero h1 { font-family:'Syne',sans-serif; font-size:clamp(1.75rem,3.5vw,2.5rem);
  font-weight:800; color:var(--text-main,#0f172a); line-height:1.15;
  margin:0 0 10px; letter-spacing:-.025em; }
.crs-hero h1 mark { background:none; color:var(--teal); border-bottom:3px solid var(--teal); }
.crs-hero p { font-size:.96rem; color:var(--text-muted,#64748b); margin:0; max-width:460px; line-height:1.65; }

/* ALERT */
.alert-msg { display:block; margin:16px 36px 0; padding:11px 16px; border-radius:10px;
  background:var(--rose-l); border:1px solid var(--rose-b); color:var(--rose); font-size:.87rem; }

/* FILTER */
.filter-wrap { padding:22px 36px 0; }
.filter-tabs { display:flex; gap:8px; flex-wrap:wrap; }
.filter-tab { display:inline-flex; align-items:center; gap:7px; padding:8px 16px; border-radius:8px;
  border:1px solid var(--border-color,#e2e8f0); background:transparent;
  color:var(--text-muted,#64748b); font-family:'DM Sans',sans-serif;
  font-size:.85rem; font-weight:500; cursor:pointer; transition:all .2s; }
.filter-tab:hover  { border-color:var(--teal-b); color:var(--teal); background:var(--teal-l); }
.filter-tab.active { background:var(--teal); border-color:var(--teal); color:#fff; font-weight:600; }

/* SECTION */
.sec-block { padding:28px 36px 0; }
.sec-hdr { display:flex; align-items:center; gap:12px; margin-bottom:18px; }
.sec-icon { width:40px; height:40px; border-radius:10px; flex-shrink:0;
  display:flex; align-items:center; justify-content:center; font-size:.95rem; }
.sec-icon.ml    { background:var(--teal-l); color:var(--teal); border:1px solid var(--teal-b); }
.sec-icon.robot { background:var(--sky-l);  color:var(--sky);  border:1px solid var(--sky-b); }
.sec-hdr h3 { font-family:'Syne',sans-serif; font-size:.97rem; font-weight:700;
  color:var(--text-main,#0f172a); margin:0 0 1px; }
.sec-hdr p  { font-size:.78rem; color:var(--text-muted,#64748b); margin:0; }
.sec-div    { flex:1; height:1px; background:var(--border-color,#e2e8f0); }

/* CARD GRID */
.crs-grid { display:grid; grid-template-columns:repeat(auto-fill,minmax(220px,1fr)); gap:18px; }

/* COURSE CARD */
.crs-card { background:var(--bg-card,#fff); border:1px solid var(--border-color,#e2e8f0);
  border-radius:14px; overflow:hidden; display:flex; flex-direction:column;
  transition:transform .22s,box-shadow .22s,border-color .22s; }
.crs-card:hover { transform:translateY(-4px); border-color:var(--teal-b);
  box-shadow:0 12px 32px rgba(0,0,0,.1); }

.card-banner { position:relative; height:116px; display:flex; align-items:center;
  justify-content:center; font-size:2.3rem; }
.banner-ml    { background:linear-gradient(135deg,#ecfdf5,#d1fae5,#a7f3d0); color:var(--teal); }
.banner-robot { background:linear-gradient(135deg,#e0f2fe,#bae6fd,#93c5fd); color:var(--sky); }
[data-theme="dark"] .banner-ml    { background:linear-gradient(135deg,#064e3b,#065f46); }
[data-theme="dark"] .banner-robot { background:linear-gradient(135deg,#0c2d4a,#0d3a6b); }

.done-badge { position:absolute; top:10px; right:10px; background:var(--teal); color:#fff;
  font-family:'Syne',sans-serif; font-size:.62rem; font-weight:700;
  padding:3px 9px; border-radius:99px; display:flex; align-items:center; gap:4px; }

.card-bd { padding:15px 15px 17px; display:flex; flex-direction:column; flex:1; }
.card-tag { font-family:'Syne',sans-serif; font-size:.62rem; font-weight:700;
  letter-spacing:.1em; text-transform:uppercase; margin-bottom:5px; color:var(--teal); }
.card-tag.sky { color:var(--sky); }
.card-ttl { font-family:'Syne',sans-serif; font-size:.88rem; font-weight:700;
  color:var(--text-main,#0f172a); line-height:1.35; margin-bottom:6px; }
.card-dsc { font-size:.78rem; color:var(--text-muted,#64748b); line-height:1.55;
  margin-bottom:13px; flex:1;
  display:-webkit-box; -webkit-line-clamp:2; -webkit-box-orient:vertical; overflow:hidden; }

.prog-wrap { margin-bottom:12px; }
.prog-lbl  { display:flex; justify-content:space-between; font-size:.69rem;
  color:var(--text-muted,#94a3b8); margin-bottom:4px; }
.prog-bg   { height:5px; background:var(--border-color,#e2e8f0); border-radius:99px; overflow:hidden; }
.prog-fill { height:100%; background:var(--teal); border-radius:99px; transition:width .6s; }

.btn-start { display:flex; align-items:center; justify-content:center; gap:8px;
  width:100%; padding:10px; border-radius:8px; background:var(--teal); color:#fff;
  border:none; cursor:pointer; font-family:'Syne',sans-serif; font-size:.82rem; font-weight:700;
  text-decoration:none; transition:all .2s; }
.btn-start:hover { background:#0f766e; color:#fff; text-decoration:none;
  box-shadow:0 4px 14px rgba(13,148,136,.35); }
.btn-start.done { background:transparent; border:1.5px solid var(--teal-b); color:var(--teal); }
.btn-start.done:hover { background:var(--teal-l); }

/* LEARNING ROOM */
.room-wrap { padding:24px 36px 60px; }
.room-topbar { display:flex; align-items:center; justify-content:space-between; flex-wrap:wrap;
  gap:12px; margin-bottom:26px; padding-bottom:16px;
  border-bottom:1px solid var(--border-color,#e2e8f0); }
.breadcrumb { font-size:.79rem; color:var(--text-muted,#94a3b8); }
.breadcrumb strong { color:var(--text-main,#0f172a); }
.btn-back { display:inline-flex; align-items:center; gap:7px; padding:8px 16px; border-radius:8px;
  border:1px solid var(--border-color,#e2e8f0); background:transparent;
  color:var(--text-muted,#64748b); font-size:.84rem; text-decoration:none; cursor:pointer; transition:all .2s; }
.btn-back:hover { border-color:var(--teal-b); color:var(--teal); background:var(--teal-l); text-decoration:none; }

.room-layout { display:grid; grid-template-columns:1fr 290px; gap:28px; align-items:start; }
@media(max-width:900px){ .room-layout { grid-template-columns:1fr; } }

.art-tag { display:inline-flex; align-items:center; gap:6px; padding:4px 12px; border-radius:99px;
  margin-bottom:12px; font-family:'Syne',sans-serif; font-size:.64rem; font-weight:700;
  text-transform:uppercase; letter-spacing:.1em; }
.art-tag.ml    { background:var(--teal-l); color:var(--teal); border:1px solid var(--teal-b); }
.art-tag.robot { background:var(--sky-l);  color:var(--sky);  border:1px solid var(--sky-b); }
.art-title { font-family:'Syne',sans-serif; font-size:clamp(1.4rem,2.8vw,1.9rem); font-weight:800;
  color:var(--text-main,#0f172a); line-height:1.2; margin-bottom:18px; letter-spacing:-.02em; }
.art-hr { border:none; height:2px; margin-bottom:26px;
  background:linear-gradient(90deg,var(--teal),var(--sky),transparent); border-radius:99px; }

.content-area { color:var(--text-muted,#475569); line-height:1.8; font-size:.95rem; }
.content-area h2 { font-family:'Syne',sans-serif; font-size:1.18rem; font-weight:700;
  color:var(--text-main,#0f172a); margin:28px 0 10px; padding-left:12px; border-left:3px solid var(--teal); }
.content-area h3 { font-family:'Syne',sans-serif; font-size:1rem; font-weight:700; color:var(--teal); margin:22px 0 8px; }
.content-area p  { margin-bottom:14px; }
.content-area ul,.content-area ol { padding-left:22px; margin-bottom:14px; }
.content-area li { margin-bottom:5px; }
.content-area strong { color:var(--text-main,#0f172a); }
.content-area code { background:var(--teal-l); color:var(--teal); padding:2px 7px; border-radius:5px; font-size:.86em; }
.content-area pre { background:var(--bg-card,#f8fafc); border:1px solid var(--border-color,#e2e8f0);
  border-left:3px solid var(--teal); border-radius:10px; padding:16px; overflow-x:auto; margin-bottom:16px; }

/* Quiz */
.quiz-section { margin-top:38px; padding:22px; background:var(--bg-card,#f8fafc);
  border:1px solid var(--border-color,#e2e8f0); border-radius:14px; }
.quiz-hdr { display:flex; align-items:center; gap:9px; margin-bottom:18px;
  padding-bottom:13px; border-bottom:1px solid var(--border-color,#e2e8f0); }
.quiz-hdr i  { color:var(--amber); }
.quiz-hdr h3 { font-family:'Syne',sans-serif; font-size:.96rem; font-weight:700;
  color:var(--text-main,#0f172a); margin:0; }
.quiz-q-card { border:1px solid var(--border-color,#e2e8f0); border-radius:10px;
  padding:16px; margin-bottom:14px; background:var(--bg-card,#fff); }
.q-num  { font-family:'Syne',sans-serif; font-size:.66rem; font-weight:700;
  color:var(--teal); text-transform:uppercase; letter-spacing:.08em; margin-bottom:6px; }
.q-text { font-weight:600; color:var(--text-main,#0f172a); margin-bottom:12px; line-height:1.5; font-size:.91rem; }
.q-options { display:flex; flex-direction:column; gap:8px; margin-bottom:12px; }
.q-options label { display:flex; align-items:center; gap:10px; padding:9px 13px; border-radius:8px;
  border:1px solid var(--border-color,#e2e8f0); cursor:pointer;
  color:var(--text-muted,#64748b); font-size:.86rem; transition:all .15s; }
.q-options label:hover { border-color:var(--teal-b); color:var(--teal); background:var(--teal-l); }
.q-options input[type=radio] { accent-color:var(--teal); width:14px; height:14px; flex-shrink:0; }
.opt-letter { font-family:'Syne',sans-serif; font-weight:700; font-size:.75rem;
  min-width:20px; color:var(--text-muted,#94a3b8); }
.btn-check { padding:8px 18px; border-radius:7px; background:var(--amber-l);
  border:1px solid var(--amber-b); color:var(--amber);
  font-family:'Syne',sans-serif; font-size:.8rem; font-weight:700; cursor:pointer; transition:all .2s; }
.btn-check:hover { background:var(--amber); color:#fff; }
.q-feedback { margin-top:9px; padding:9px 13px; border-radius:8px;
  font-size:.83rem; font-weight:500; display:none; }
.q-feedback.correct { background:var(--teal-l); color:var(--teal); border:1px solid var(--teal-b); display:block; }
.q-feedback.wrong   { background:var(--rose-l); color:var(--rose); border:1px solid var(--rose-b); display:block; }
.no-quiz { color:var(--text-muted,#94a3b8); font-size:.86rem; padding:10px 0; }

/* Sidebar */
.room-sidebar { display:flex; flex-direction:column; gap:16px; position:sticky; top:20px; }
.cta-card { padding:22px; border-radius:14px;
  background:linear-gradient(135deg,var(--teal-l),rgba(14,165,233,.08)); border:1px solid var(--teal-b); }
.cta-card h5 { font-family:'Syne',sans-serif; font-size:.9rem; font-weight:700;
  color:var(--text-main,#0f172a); margin:0 0 7px; display:flex; align-items:center; gap:7px; }
.cta-card h5 i { color:var(--amber); }
.cta-card p  { font-size:.81rem; color:var(--text-muted,#64748b); margin-bottom:15px; line-height:1.55; }
.btn-complete { display:flex; align-items:center; justify-content:center; gap:8px;
  width:100%; padding:11px; border-radius:8px; background:var(--teal); color:#fff; border:none;
  cursor:pointer; font-family:'Syne',sans-serif; font-size:.86rem; font-weight:700;
  text-decoration:none; transition:all .2s; }
.btn-complete:hover { background:#0f766e; color:#fff; text-decoration:none; box-shadow:0 4px 14px rgba(13,148,136,.3); }
.btn-complete.completed { background:var(--teal-l); color:var(--teal); border:1.5px solid var(--teal-b);
  cursor:not-allowed; opacity:.85; }
.sc-card { padding:18px; border-radius:14px; background:var(--bg-card,#fff);
  border:1px solid var(--border-color,#e2e8f0); }
.sc-card h5 { font-family:'Syne',sans-serif; font-size:.84rem; font-weight:700;
  color:var(--text-main,#0f172a); margin:0 0 12px; display:flex; align-items:center; gap:7px; }
.sc-card h5 i { color:var(--teal); }
.takeaway-list { list-style:none; padding:0; margin:0; }
.takeaway-list li { display:flex; align-items:flex-start; gap:9px; font-size:.81rem;
  color:var(--text-muted,#64748b); padding:7px 0;
  border-bottom:1px solid var(--border-color,#e2e8f0); line-height:1.5; }
.takeaway-list li:last-child { border-bottom:none; }
.takeaway-list li i    { color:var(--teal); font-size:.72rem; margin-top:3px; flex-shrink:0; }
.takeaway-list li span { flex:1; }
.no-takeaways { color:var(--text-muted,#94a3b8); font-size:.82rem; margin:0; }

/* Responsive */
@media(max-width:768px){
  .crs-hero,.room-wrap { padding-left:18px; padding-right:18px; }
  .crs-hero::after { left:18px; right:18px; }
  .filter-wrap,.sec-block { padding-left:18px; padding-right:18px; }
  .crs-grid { grid-template-columns:repeat(auto-fill,minmax(190px,1fr)); gap:13px; }
}
</style>
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
<div class="crs">
<asp:MultiView ID="MainView" runat="server" ActiveViewIndex="0">

  <%-- ════════ VIEW 0 : CATALOGUE ════════ --%>
  <asp:View ID="ViewCatalogue" runat="server">

    <div class="crs-hero">
      <div class="hero-pill"><i class="fas fa-graduation-cap"></i> My Learning</div>
      <h1>Learn <mark>Smarter</mark>,<br>Build Better.</h1>
      <p>Choose a module, read the lesson, then test your knowledge with a quiz.</p>
    </div>

    <asp:Label ID="lblAlert" runat="server" CssClass="alert-msg" Visible="false"></asp:Label>

    <div class="filter-wrap">
      <div class="filter-tabs">
        <button type="button" class="filter-tab active" data-filter="all"   onclick="filterSec('all',this)">
          <i class="fas fa-th-large"></i> All Modules</button>
        <button type="button" class="filter-tab"        data-filter="ml"   onclick="filterSec('ml',this)">
          <i class="fas fa-brain"></i> Machine Learning</button>
        <button type="button" class="filter-tab"        data-filter="robot" onclick="filterSec('robot',this)">
          <i class="fas fa-microchip"></i> Robotics</button>
      </div>
    </div>

    <div id="sec-ml" class="sec-block" style="margin-bottom:8px">
      <div class="sec-hdr">
        <div class="sec-icon ml"><i class="fas fa-brain"></i></div>
        <div>
          <h3>Machine Learning</h3>
          <p><asp:Label ID="lblMLCount" runat="server">0 modules</asp:Label> &middot; From AI basics to Python tools</p>
        </div>
        <div class="sec-div"></div>
      </div>
      <div class="crs-grid">
        <asp:Repeater ID="rptML" runat="server" OnItemCommand="rptCourses_ItemCommand">
          <ItemTemplate>
            <div class="crs-card">
              <div class="card-banner banner-ml">
                <i class="fas <%# Eval("ImageURL") %>"></i>
                <%# IsCompleted(Eval("IsCompleted")) ? "<div class='done-badge'><i class='fas fa-check'></i> Done</div>" : "" %>
              </div>
              <div class="card-bd">
                <div class="card-tag">Machine Learning</div>
                <div class="card-ttl"><%# Eval("Title") %></div>
                <div class="card-dsc"><%# Eval("Description") %></div>
                <div class="prog-wrap">
                  <div class="prog-lbl"><span>Progress</span><span><%# IsCompleted(Eval("IsCompleted")) ? "100%" : "0%" %></span></div>
                  <div class="prog-bg">
                    <div class="prog-fill" style='<%# "width:"+(IsCompleted(Eval("IsCompleted"))?"100%":"0%") %>'></div>
                  </div>
                </div>
                <asp:LinkButton runat="server" CommandName="OpenCourse" CommandArgument='<%# Eval("ArticleID") %>'
                  CssClass='<%# "btn-start"+(IsCompleted(Eval("IsCompleted"))?" done":"") %>'>
                  <%# IsCompleted(Eval("IsCompleted")) ? "<i class='fas fa-check-circle'></i> Review Again" : "<i class='fas fa-play-circle'></i> Start Learning" %>
                </asp:LinkButton>
              </div>
            </div>
          </ItemTemplate>
        </asp:Repeater>
      </div>
    </div>

    <div id="sec-robot" class="sec-block" style="padding-bottom:48px">
      <div class="sec-hdr">
        <div class="sec-icon robot"><i class="fas fa-microchip"></i></div>
        <div>
          <h3>Robotics</h3>
          <p><asp:Label ID="lblRobotCount" runat="server">0 modules</asp:Label> &middot; From sensors to building your first robot</p>
        </div>
        <div class="sec-div"></div>
      </div>
      <div class="crs-grid">
        <asp:Repeater ID="rptRobot" runat="server" OnItemCommand="rptCourses_ItemCommand">
          <ItemTemplate>
            <div class="crs-card">
              <div class="card-banner banner-robot">
                <i class="fas <%# Eval("ImageURL") %>"></i>
                <%# IsCompleted(Eval("IsCompleted")) ? "<div class='done-badge'><i class='fas fa-check'></i> Done</div>" : "" %>
              </div>
              <div class="card-bd">
                <div class="card-tag sky">Robotics</div>
                <div class="card-ttl"><%# Eval("Title") %></div>
                <div class="card-dsc"><%# Eval("Description") %></div>
                <div class="prog-wrap">
                  <div class="prog-lbl"><span>Progress</span><span><%# IsCompleted(Eval("IsCompleted")) ? "100%" : "0%" %></span></div>
                  <div class="prog-bg">
                    <div class="prog-fill" style='<%# "width:"+(IsCompleted(Eval("IsCompleted"))?"100%":"0%") %>'></div>
                  </div>
                </div>
                <asp:LinkButton runat="server" CommandName="OpenCourse" CommandArgument='<%# Eval("ArticleID") %>'
                  CssClass='<%# "btn-start"+(IsCompleted(Eval("IsCompleted"))?" done":"") %>'>
                  <%# IsCompleted(Eval("IsCompleted")) ? "<i class='fas fa-check-circle'></i> Review Again" : "<i class='fas fa-play-circle'></i> Start Learning" %>
                </asp:LinkButton>
              </div>
            </div>
          </ItemTemplate>
        </asp:Repeater>
      </div>
    </div>

  </asp:View>

  <%-- ════════ VIEW 1 : LEARNING ROOM ════════ --%>
  <asp:View ID="ViewRoom" runat="server">
    <div class="room-wrap">

      <div class="room-topbar">
        <div class="breadcrumb">
          My Learning &rsaquo; <asp:Label ID="lblBreadCat" runat="server"></asp:Label> &rsaquo;
          <strong><asp:Label ID="lblBreadTitle" runat="server"></asp:Label></strong>
        </div>
        <asp:LinkButton ID="btnBack" runat="server" OnClick="btnBack_Click" CssClass="btn-back">
          <i class="fas fa-arrow-left"></i> Back to Courses
        </asp:LinkButton>
      </div>

      <div class="room-layout">
        <div class="room-main">
          <asp:Label ID="lblCatTag" runat="server"></asp:Label>
          <h1 class="art-title"><asp:Label ID="lblTitle" runat="server"></asp:Label></h1>
          <hr class="art-hr" />
          <div class="content-area">
            <asp:Literal ID="litContent" runat="server"></asp:Literal>
          </div>
          <div class="quiz-section">
            <div class="quiz-hdr">
              <i class="fas fa-bolt"></i>
              <h3>Knowledge Check</h3>
            </div>
            <asp:Literal ID="litQuiz" runat="server"></asp:Literal>
          </div>
        </div>

        <div class="room-sidebar">
          <div class="cta-card">
            <h5><i class="fas fa-trophy"></i> Ready to level up?</h5>
            <p>Finished reading? Mark this module complete and track your progress.</p>
            <asp:LinkButton ID="btnMarkComplete" runat="server" OnClick="btnMarkComplete_Click" CssClass="btn-complete">
              <i class="fas fa-check-circle"></i> Mark as Completed
            </asp:LinkButton>
          </div>
          <div class="sc-card">
            <h5><i class="fas fa-check-double"></i> Key Takeaways</h5>
            <asp:Literal ID="litTakeaways" runat="server"></asp:Literal>
          </div>
        </div>
      </div>

    </div>
  </asp:View>

</asp:MultiView>
</div>

<script>
    function filterSec(cat, btn) {
        localStorage.setItem('courseFilter', cat);
        var ml = document.getElementById('sec-ml'), rb = document.getElementById('sec-robot');
        if (ml) ml.style.display = (cat === 'robot') ? 'none' : 'block';
        if (rb) rb.style.display = (cat === 'ml') ? 'none' : 'block';
        document.querySelectorAll('.filter-tab').forEach(function (b) { b.classList.remove('active'); });
        btn.classList.add('active');
    }
    window.addEventListener('DOMContentLoaded', function () {
        var saved = localStorage.getItem('courseFilter') || 'all';
        var ml = document.getElementById('sec-ml'), rb = document.getElementById('sec-robot');
        if (ml) ml.style.display = (saved === 'robot') ? 'none' : 'block';
        if (rb) rb.style.display = (saved === 'ml') ? 'none' : 'block';
        document.querySelectorAll('.filter-tab').forEach(function (b) {
            b.classList.remove('active');
            if (b.getAttribute('data-filter') === saved) b.classList.add('active');
        });
    });
    function checkAnswer(btn) {
        var qid = btn.getAttribute('data-qid');
        var correct = btn.getAttribute('data-correct').toUpperCase();
        var sel = document.querySelector('input[name="q' + qid + '"]:checked');
        var fb = document.getElementById('fb' + qid);
        if (!fb) return;
        if (!sel) {
            fb.className = 'q-feedback wrong';
            fb.innerHTML = '<i class="fas fa-exclamation-circle"></i> Please select an answer first.';
            return;
        }
        if (sel.value.toUpperCase() === correct) {
            fb.className = 'q-feedback correct';
            fb.innerHTML = '<i class="fas fa-check-circle"></i> Correct! Well done.';
        } else {
            var ci = document.querySelector('input[name="q' + qid + '"][value="' + correct + '"]');
            var hint = ci ? ci.parentElement.textContent.trim() : correct;
            fb.className = 'q-feedback wrong';
            fb.innerHTML = '<i class="fas fa-times-circle"></i> Not quite. Correct answer: <strong>' + hint + '</strong>';
        }
    }
</script>
</asp:Content>