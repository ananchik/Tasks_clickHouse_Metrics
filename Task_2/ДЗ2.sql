
-- вывод первых 5 имен героев, которые потратили максимальное кол-во золота за все матчи, в которых участвовали
with g_p_hero as
         (-- сколько потрачено золота на героя
             select p.hero_id
                  , p.match_id
                  , sum(gold_spent) over (partition by hero_id) as gold_spent_on_hero_id
             from players p
             where hero_id > 0
         )
select max(gold_spent_on_hero_id) as gold_spent_for_heroId
     , gph.hero_id
     , hn.localized_name
from g_p_hero gph join hero_names hn
    on hn.hero_id = gph.hero_id
group by gph.hero_id, hn.localized_name
order by max(gold_spent_on_hero_id) desc
limit 5;

-- вывод первых 5 имен героев, которые потратили максимальное кол-во золота
-- и получили максимальное кол-во урона за все матчи, в которых участвовали
with g_p_hero as
         (-- сколько потрачено золота и сделано убийств героем за матчи, в которых участвовал
             select p.hero_id
                  , p.match_id
                  , sum(kills) over (partition by hero_id) as kills_on_hero_id
                  , sum(gold_spent) over (partition by hero_id) as gold_spent_on_hero_id
             from players p
             where hero_id > 0
         )
select max(kills_on_hero_id) as max_kills_on_heroId
     , max(gold_spent_on_hero_id) as gold_spent_for_heroId
     , gph.hero_id
     , hn.localized_name
from g_p_hero gph join hero_names hn
    on hn.hero_id = gph.hero_id
group by gph.hero_id, hn.localized_name
order by max(kills_on_hero_id) desc
limit 5;

-- кол-во матчей для каждого героя, в которых одержала победу светлая сторона
with brightHero as (
    select p.hero_id
         , m.radiant_win
         , m.match_id
         , count(m.match_id) over (partition by hn.hero_id) as cnt_hero_per_brightSide
         , hn.localized_name
    from match m
             join players p
                  on m.match_id = p.match_id
             join hero_names hn on p.hero_id = hn.hero_id
    where radiant_win = 'True'
      and m.match_id > 0
    order by p.hero_id
)
select cnt_hero_per_brightSide,
       hero_id,
       localized_name
from brightHero
group by hero_id, localized_name, cnt_hero_per_brightSide
order by cnt_hero_per_brightSide desc
limit 5;

-- популярые предметы в матчах, где одерживала победу светлая сторона (аналогичный запрос и для темной стороны)
with brigt_item as (
    select pl.item_id as bright_item
         , m.radiant_win
         , ii.item_name --, p.item_0, p.item_1
         , m.match_id as bright_match
         , count(m.match_id) over (partition by ii.item_id) as cnt1
    from purchase_log pl
             join match m
                  on m.match_id = pl.match_id
             inner join item_ids ii on pl.item_id = ii.item_id
-- join players p on m.match_id = p.match_id
    where m.radiant_win = 'True'
    order by m.radiant_win desc, ii.item_id desc
),
     dark_item as (
select pl.item_id as dark_item
         , m.radiant_win
         , ii.item_name --, p.item_0, p.item_1
         , m.match_id as dark_match
         , count(m.match_id) over (partition by ii.item_id) as cnt2
    from purchase_log pl
             join match m
                  on m.match_id = pl.match_id
             inner join item_ids ii on pl.item_id = ii.item_id
-- join players p on m.match_id = p.match_id
    where m.radiant_win = 'False'
    order by m.radiant_win desc, ii.item_id desc
    --limit 5
)

select bright_item, item_name, max(cnt1) from brigt_item
group by bright_item, item_name
order by max(cnt1) desc
limit 5;

-- топ 5 игроков с наибольшим кол-вом побед
select p.account_id
     --, pr.total_matches
     , sum(pr.total_wins) as sum_wins
from players p join player_ratings pr on p.account_id = pr.account_id
where p.account_id > 0
group by p.account_id
order by sum(pr.total_wins) desc
limit 5;

