using Engine;
using Gee;

class GameMenuView : View2D
{
    private ScoringView? score_view = null;
    private ArrayList<MenuTextButton> buttons = new ArrayList<MenuTextButton>();
    private ArrayList<MenuTextButton> observer_buttons = new ArrayList<MenuTextButton>();

    private GameRenderContext context;
    private ServerSettings settings;
    private bool observing;

    private Sound hint_sound;
    private float start_time;
    private LabelControl timer;
    private LabelControl furiten;
    private LabelControl tutorial;

    private MenuTextButton chii;
    private MenuTextButton pon;
    private MenuTextButton kan;
    private MenuTextButton riichi;
    private MenuTextButton open_riichi;
    private MenuTextButton tsumo;
    private MenuTextButton ron;
    private MenuTextButton conti;
    private MenuTextButton void_hand;

    private MenuTextButton next;
    private MenuTextButton prev;

    public signal void chii_pressed();
    public signal void pon_pressed();
    public signal void kan_pressed();
    public signal void riichi_pressed(bool open);
    public signal void tsumo_pressed();
    public signal void ron_pressed();
    public signal void continue_pressed();
    public signal void void_hand_pressed();
    public signal void display_score_pressed();
    public signal void score_finished();

    public signal void observe_next_pressed();
    public signal void observe_prev_pressed();

    private void tutorial_answer(string title, string body)
    {
        tutorial.text = "[초보교실] " + title + " — " + body;
    }

    private void refresh_tutorial_prompt()
    {
        if (observing)
            return;

        ArrayList<string> legal = new ArrayList<string>();
        if (ron.enabled) legal.add("론");
        if (tsumo.enabled) legal.add("쯔모");
        if (pon.enabled) legal.add("퐁");
        if (chii.enabled) legal.add("치");
        if (kan.enabled) legal.add("깡");
        if (riichi.enabled) legal.add("리치");
        if (conti.enabled) legal.add("넘기기");

        if (legal.size == 0)
        {
            tutorial.text = "[초보교실] 내 차례야. 손패를 보고 버릴 패를 선택해. 완성형만 보지 말고 다음에 들어올 패까지 생각해보자.";
            return;
        }

        string choices = "";
        foreach (string s in legal)
        {
            if (choices.length > 0) choices += " / ";
            choices += s;
        }
        tutorial.text = "[문제] 지금 가능한 행동: " + choices + "  |  어떤 행동을 할까? 버튼을 고르면 바로 실제 게임에 반영돼.";
    }

    private void press_chii()
    {
        tutorial_answer("치(Chii)", "왼쪽 플레이어가 버린 패를 가져와 연속된 숫자 3장을 만드는 호출이야. 호출하면 손이 공개되고 리치는 할 수 없어.");
        chii_pressed();
    }
    private void press_pon()
    {
        tutorial_answer("퐁(Pon)", "누구의 버림패든 같은 패 2장이 손에 있으면 같은 패 3장 묶음을 만들 수 있어. 자패도 퐁할 수 있어.");
        pon_pressed();
    }
    private void press_kan()
    {
        tutorial_answer("깡(Kan)", "같은 패 4장을 한 묶음으로 만드는 행동이야. 종류에 따라 영상개화·창깡·도라 추가 같은 변화가 생길 수 있어.");
        kan_pressed();
    }
    private void press_riichi()
    {
        bool state = open_riichi.enabled;
        tutorial_answer("리치(Riichi)", "멘젠 상태에서 텐파이일 때 1000점을 걸고 선언해. 이후에는 기본적으로 손 모양을 바꾸지 않고 화료패를 기다려.");
        riichi_pressed(false);
        if (state)
            open_riichi.enabled = false;
    }
    private void press_open_riichi()
    {
        bool state = riichi.enabled;
        tutorial_answer("오픈 리치", "일반 리치와 달리 손패를 공개하는 선택 규칙이야. 방 규칙에서 허용된 경우에만 사용할 수 있어.");
        riichi_pressed(true);
        if (state)
            riichi.enabled = false;
    }
    private void press_tsumo()
    {
        tutorial_answer("쯔모(Tsumo)", "내가 직접 뽑은 패로 화료한 거야. 엔진이 역이 있는 합법 화료라고 판정했기 때문에 버튼이 활성화됐어.");
        tsumo_pressed();
    }
    private void press_ron()
    {
        tutorial_answer("론(Ron)", "상대가 버린 패로 화료하는 거야. 후리텐과 역 조건까지 엔진 검사를 통과했을 때만 활성화돼.");
        ron_pressed();
    }
    private void press_continue()
    {
        tutorial_answer("넘기기", "호출이나 론이 가능해도 반드시 해야 하는 건 아니야. 패의 가치와 손의 속도를 보고 넘기는 선택도 중요해.");
        continue_pressed();
    }
    private void press_void_hand()
    {
        tutorial_answer("구종구패", "첫 순에 특정 조건의 요구패가 너무 많이 모였을 때 유국을 선언할 수 있는 선택 규칙이야.");
        void_hand_pressed();
    }

    private void press_next() { observe_next_pressed(); score_view.next(); }
    private void press_prev() { observe_prev_pressed(); score_view.prev(); }

    public GameMenuView(GameRenderContext context, ServerSettings settings, int player_index, bool observing)
    {
        this.context = context;
        this.settings = settings;
        this.player_index = player_index;
        this.observing = observing;

        score_view = new ScoringView(context, player_index);
        score_view.score_finished.connect(do_score_finished);
    }

    public override void added()
    {
        hint_sound = store.audio_player.load_sound("hint");

        int padding = 30;
        timer = new LabelControl();
        add_child(timer);
        timer.inner_anchor = Vec2(1, 0);
        timer.outer_anchor = Vec2(1, 0);
        timer.position = Vec2(-padding, padding / 2);
        timer.font_size = 60;
        timer.visible = false;

        furiten = new LabelControl();
        add_child(furiten);
        furiten.inner_anchor = Vec2(0, 0);
        furiten.outer_anchor = Vec2(0, 0);
        furiten.position = Vec2(padding, padding / 2);
        furiten.font_size = 30;
        furiten.visible = false;
        furiten.text = "후리텐";
        furiten.color = Color.red();

        tutorial = new LabelControl();
        add_child(tutorial);
        tutorial.inner_anchor = Vec2(0.5f, 1);
        tutorial.outer_anchor = Vec2(0.5f, 1);
        tutorial.position = Vec2(0, -70);
        tutorial.font_size = 24;
        tutorial.visible = !observing;
        tutorial.text = "[초보교실] 엔진의 합법 행동 판정을 그대로 사용해 설명해줄게.";

        chii = new MenuTextButton("MenuButtonSmall", "치");
        pon = new MenuTextButton("MenuButtonSmall", "퐁");
        kan = new MenuTextButton("MenuButtonSmall", "깡");
        riichi = new MenuTextButton("MenuButtonSmall", "리치");
        open_riichi = new MenuTextButton("MenuButtonSmall", "오픈 리치");
        tsumo = new MenuTextButton("MenuButtonSmall", "쯔모");
        ron = new MenuTextButton("MenuButtonSmall", "론");
        conti = new MenuTextButton("MenuButtonSmall", "넘기기");
        void_hand = new MenuTextButton("MenuButtonSmall", "구종구패");

        next = new MenuTextButton("MenuButtonSmall", "다음");
        prev = new MenuTextButton("MenuButtonSmall", "이전");

        chii.clicked.connect(press_chii);
        pon.clicked.connect(press_pon);
        kan.clicked.connect(press_kan);
        riichi.clicked.connect(press_riichi);
        open_riichi.clicked.connect(press_open_riichi);
        tsumo.clicked.connect(press_tsumo);
        ron.clicked.connect(press_ron);
        conti.clicked.connect(press_continue);
        void_hand.clicked.connect(press_void_hand);

        next.clicked.connect(press_next);
        prev.clicked.connect(press_prev);

        buttons.add(chii);
        buttons.add(pon);
        buttons.add(kan);
        buttons.add(riichi);
        buttons.add(open_riichi);
        buttons.add(tsumo);
        buttons.add(ron);
        buttons.add(conti);
        buttons.add(void_hand);

        observer_buttons.add(prev);
        observer_buttons.add(next);

        foreach (var button in buttons)
        {
            add_child(button);
            button.enabled = false;
            button.inner_anchor = Vec2(0.5f, 0);
            button.outer_anchor = Vec2(0.5f, 0);
            button.font_size = 24;
            button.visible = !observing;
        }

        foreach (var button in observer_buttons)
        {
            add_child(button);
            button.inner_anchor = Vec2(0.5f, 0);
            button.outer_anchor = Vec2(0.5f, 0);
            button.font_size = 24;
            button.visible = observing;
        }

        void_hand.visible = false;
        open_riichi.visible = open_riichi.visible && settings.open_riichi == OnOffEnum.ON;
        position_buttons(buttons);
        position_buttons(observer_buttons);

        add_child(score_view);
    }

    private void position_buttons(ArrayList<MenuTextButton> buttons)
    {
        float p = 0;
        float width = 0;

        foreach (var button in buttons)
            if (button.visible)
                width += button.size.width / 2;

        foreach (var button in buttons)
        {
            if (!button.visible)
                continue;

            button.position = Vec2(button.size.width / 2 - width + p, 0);
            p += button.size.width;
        }
    }

    protected override void key_press(KeyArgs key)
    {
        if (key.handled)
            return;

        key.handled = true;

        if (key.scancode == ScanCode.TAB && !key.repeat)
        {
            if (key.down)
                display_score();
            else
                hide_score();
        }
        else
            key.handled = false;
    }

    public void set_chii(bool enabled) { chii.enabled = enabled; refresh_tutorial_prompt(); }
    public void set_pon(bool enabled) { pon.enabled = enabled; refresh_tutorial_prompt(); }
    public void set_kan(bool enabled) { kan.enabled = enabled; refresh_tutorial_prompt(); }
    public void set_riichi(bool enabled) { riichi.enabled = enabled; open_riichi.enabled = enabled; refresh_tutorial_prompt(); }
    public void set_tsumo(bool enabled) { tsumo.enabled = enabled; refresh_tutorial_prompt(); }
    public void set_ron(bool enabled) { ron.enabled = enabled; refresh_tutorial_prompt(); }

    public void set_continue(bool enabled)
    {
        if (enabled)
            hint_sound.play();
        conti.enabled = enabled;
        refresh_tutorial_prompt();
    }

    public void set_void_hand(bool enabled)
    {
        void_hand.visible = enabled;
        void_hand.enabled = enabled;
        position_buttons(buttons);
        refresh_tutorial_prompt();
    }

    public void set_furiten(bool enabled)
    {
        furiten.visible = enabled;
        if (enabled)
            tutorial.text = "[초보교실] 후리텐 상태야. 현재는 상대의 버림패로 론할 수 없는 상태이므로 버림패와 대기패를 확인해봐.";
    }

    public void set_move_timer(bool enabled)
    {
        if (timer.visible && enabled)
            return;

        start_time = 0;
        timer.visible = enabled;
    }

    public void update_scores(RoundScoreState[] scores) { score_view.update_scores(scores); }
    public void game_over() { score_view.display(true); }

    public void round_finished()
    {
        score_view.display(true);
        foreach (var button in observer_buttons)
            button.enabled = false;
    }

    public void display_score() { score_view.display(false); }
    public void hide_score() { score_view.hide(); }

    public void display_disconnected()
    {
        InformationMenuView view = new InformationMenuView("서버 연결이 끊어졌습니다");
        add_child(view);
        view.back.connect(info_menu_finished);
    }

    public void display_player_left(string name)
    {
        InformationMenuView view = new InformationMenuView(name + " 님이 게임을 나갔습니다");
        add_child(view);
        view.back.connect(info_menu_finished);
    }

    private void info_menu_finished(MenuSubView view) { remove_child(view); }
    private void do_score_finished() { score_finished(); }

    protected override void process(DeltaArgs delta)
    {
        if (start_time == 0)
            start_time = delta.time;

        if (!timer.visible)
            return;

        int t = int.max((int)(start_time + context.server_times.decision_time - delta.time), 0);
        if (t == context.server_times.decision_time)
            t--;

        if (t < 0)
        {
            timer.visible = false;
            return;
        }

        timer.color = t < 3 ? Color.red() : Color.white();
        string str = t.to_string();
        if (str != timer.text)
            timer.text = str;
    }

    public int player_index { get; set; }
}
