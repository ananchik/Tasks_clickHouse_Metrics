
-- 1 задание
select count(first_blood_time/60) as cnt_first_bl_min
from match
where (first_blood_time/60) > 1 and (first_blood_time/60) < 3;

-- 2 задание
select p.account_id
--      , sum(m.positive_votes) as pstv_sum
--      , sum(m.negative_votes) as ngtv_sum
from players p join match m on p.match_id = m.match_id
where p.account_id > 0
  and m.radiant_win = 'True'
group by p.account_id
having sum(m.negative_votes) < sum(m.positive_votes)
order by p.account_id;

-- 3 задание
select p.account_id
     , avg(m.duration) as avg_duration
from players p join match m on m.match_id = p.match_id
group by p.account_id
order by p.account_id;

-- 4 задание
select distinct p.hero_id
--      , p.account_id
     , sum(p.gold_spent) as sum_gold_spent
     , avg(m.duration) as avg_duration
from players p join match m on m.match_id = p.match_id
where p.account_id = 0
group by p.hero_id --, p.account_id
order by p.hero_id;

-- 5 задание
select localized_name
     , hr.hero_id
     , count(p.match_id) as match_cnt
     , avg(p.kills) as avg_kills
     , min(p.deaths) as min_depths
     , sum(p.match_id) as match_sum
     , max(p.gold_spent) as max_gold_spent
     , sum(m.positive_votes) as pstv_voice_sum
     , sum(m.negative_votes) as ngtv_voice_sum
from hero_names hr left join players p on p.hero_id = hr.hero_id
join match m on m.match_id = p.match_id
group by localized_name, hr.hero_id
order by hr.hero_id;

-- 6 задание
select m.match_id
--      , m.start_time
--      , pl.player_slot
--      , sum(pl.time) as time_sum
from match m join purchase_log pl on m.match_id = pl.match_id
where pl.item_id = 42
group by m.match_id, pl.player_slot --, m.start_time
having sum(pl.time) > 100 and pl.player_slot > 0
order by sum(pl.time);

select item_id, sum(time)
from purchase_log
where player_slot>0 and item_id = 42
group by item_id
order by item_id;

--7 задание
select *
from match m join purchase_log pl on m.match_id = pl.match_id
limit 20;

