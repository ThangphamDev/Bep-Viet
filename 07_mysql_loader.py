#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
BẾP VIỆT – 07_mysql_loader.py (integrated)
- Nạp toàn bộ CSV từ bước 04 (units, unit_conversions, ingredients, aliases, recipes, recipe_ingredients, tags, recipe_tags)
- Tạo & cập nhật bảng map: ingredient_key_map(id_key -> ingredient_id UUID)
- (MỚI) Nạp prices.csv -> ingredient_prices (JOIN theo ingredient_key_map)
Yêu cầu:
    pip install mysql-connector-python
Cách chạy:
    python 07_mysql_loader.py --host 127.0.0.1 --user root --password 123 --database bepviet --csvdir data_csv-v2
"""
import argparse, csv, uuid, os, datetime as dt
import mysql.connector as mysql

def read_csv(path):
    if not os.path.exists(path):
        return []
    with open(path, newline="", encoding="utf-8") as f:
        return list(csv.DictReader(f))

# ---------- Ensure tables (idempotent) ----------
DDL_ING_KEY_MAP = """
CREATE TABLE IF NOT EXISTS ingredient_key_map (
  id_key VARCHAR(64) PRIMARY KEY,
  ingredient_id CHAR(36) NOT NULL,
  UNIQUE KEY uk_ing (ingredient_id),
  CONSTRAINT fk_ing_map FOREIGN KEY (ingredient_id) REFERENCES ingredients(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
"""

DDL_ING_PRICES = """
CREATE TABLE IF NOT EXISTS ingredient_prices (
  id CHAR(36) PRIMARY KEY,
  ingredient_id CHAR(36) NOT NULL,
  region ENUM('BAC','TRUNG','NAM') NOT NULL,
  unit VARCHAR(16) NOT NULL,
  price_per_unit DECIMAL(16,6) NOT NULL,
  currency VARCHAR(16) NOT NULL,
  source VARCHAR(255),
  last_updated DATETIME,
  UNIQUE KEY uniq_price (ingredient_id, region, unit),
  KEY idx_ing (ingredient_id),
  CONSTRAINT fk_price_ing FOREIGN KEY (ingredient_id) REFERENCES ingredients(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
"""

def ensure_aux_tables(cur):
    cur.execute(DDL_ING_KEY_MAP)
    cur.execute(DDL_ING_PRICES)

# ---------- Upserts core ----------
def upsert_units(cur, rows):
    for r in rows:
        cur.execute("""
            INSERT INTO units(code,name,type) VALUES(%s,%s,%s)
            ON DUPLICATE KEY UPDATE name=VALUES(name), type=VALUES(type)
        """, (r["code"], r["name"], r["type"]))

def upsert_unit_conversions(cur, rows):
    for r in rows:
        cur.execute("""
            INSERT INTO unit_conversions(from_code,to_code,factor,offset) VALUES(%s,%s,%s,%s)
            ON DUPLICATE KEY UPDATE factor=VALUES(factor), offset=VALUES(offset)
        """, (r["from_code"], r["to_code"], r["factor"], r["offset"]))

def upsert_ingredients(cur, rows):
    # map key->uuid to return
    mapping = {}
    for r in rows:
        ing_uuid = str(uuid.uuid4())
        cur.execute("""
            INSERT INTO ingredients(id,name,default_unit,category_id,shelf_life_days,perishable,notes)
            VALUES(%s,%s,%s,%s,%s,%s,%s)
            ON DUPLICATE KEY UPDATE name=VALUES(name), default_unit=VALUES(default_unit)
        """, (ing_uuid, r["name"], r["default_unit"] or "g", r.get("category_id") or None,
              r.get("shelf_life_days") or None, int(r.get("perishable") or 1), r.get("notes") or None))
        mapping[r["id_key"]] = ing_uuid
    return mapping

def upsert_ing_key_map(cur, ing_map):
    for id_key, ing_uuid in ing_map.items():
        cur.execute("""
            INSERT INTO ingredient_key_map(id_key, ingredient_id)
            VALUES(%s, %s)
            ON DUPLICATE KEY UPDATE ingredient_id = VALUES(ingredient_id)
        """, (id_key, ing_uuid))

def upsert_aliases(cur, mapping, rows):
    for r in rows:
        ing_id = mapping.get(r["ingredient_key"]);
        if not ing_id:
            continue
        cur.execute("""
            INSERT INTO ingredient_aliases(id,ingredient_id,alias)
            VALUES(UUID(),%s,%s)
            ON DUPLICATE KEY UPDATE alias=VALUES(alias)
        """, (ing_id, r["alias"]))

def upsert_recipes(cur, rows):
    rmap = {}
    for r in rows:
        rid = str(uuid.uuid4())
        cur.execute("""
            INSERT INTO recipes(id,name_vi,meal_type,difficulty,cook_time_min,region,image_url,instructions_md)
            VALUES(%s,%s,'DINNER',2,%s,%s,%s,'')
            ON DUPLICATE KEY UPDATE name_vi=VALUES(name_vi), cook_time_min=VALUES(cook_time_min), image_url=VALUES(image_url)
        """, (rid, r["title"], r.get("total_minutes") or None, r.get("region") or None, r.get("image_url") or None))
        rmap[r["id_key"]] = rid
    return rmap

def upsert_recipe_ingredients(cur, ing_map, rec_map, rows):
    for r in rows:
        ing_id = ing_map.get(r["ingredient_key"]);
        rec_id = rec_map.get(r["recipe_id_key"])
        if not ing_id or not rec_id:
            continue
        cur.execute("""
            INSERT INTO recipe_ingredients(id,recipe_id,ingredient_id,quantity,unit,note)
            VALUES(UUID(),%s,%s,%s,%s,%s)
            ON DUPLICATE KEY UPDATE quantity=VALUES(quantity), unit=VALUES(unit), note=VALUES(note)
        """, (rec_id, ing_id, r.get("quantity") or None, r.get("unit") or None, r.get("raw_line") or None))

def upsert_tags(cur, rows):
    seen = set()
    for r in rows:
        name = r.get("name")
        if not name or name in seen: 
            continue
        seen.add(name)
        cur.execute("""
            INSERT INTO tags(id,name,type) VALUES(UUID(),%s,%s)
            ON DUPLICATE KEY UPDATE type=VALUES(type)
        """, (name, r.get("type") or None))

def upsert_recipe_tags(cur, rec_map, rows):
    for r in rows:
        rec_id = rec_map.get(r["recipe_id_key"])
        if not rec_id: 
            continue
        cur.execute("SELECT id FROM tags WHERE name=%s", (r["tag_name"],))
        tag = cur.fetchone()
        if not tag: 
            continue
        cur.execute("""
            INSERT INTO recipe_tags(recipe_id,tag_id) VALUES(%s,%s)
            ON DUPLICATE KEY UPDATE tag_id=VALUES(tag_id)
        """, (rec_id, tag[0]))

# ---------- Prices ----------
def upsert_prices(cur, ing_map, rows):
    """rows: ingredient_key,region,unit,price_per_unit,currency,source,last_updated"""
    for r in rows:
        ing_id = ing_map.get(r["ingredient_key"])
        if not ing_id:
            # thử map qua ingredient_key_map (trường hợp load lại, map cũ còn)
            cur.execute("SELECT ingredient_id FROM ingredient_key_map WHERE id_key=%s", (r["ingredient_key"],))
            row = cur.fetchone()
            if row:
                ing_id = row[0]
            else:
                continue  # bỏ qua nếu chưa có nguyên liệu

        # chuẩn hóa giá & thời gian
        price = r.get("price_per_unit")
        try:
            price = float(price)
        except Exception:
            continue
        last_updated = r.get("last_updated") or None

        cur.execute("""
            INSERT INTO ingredient_prices(id, ingredient_id, region, unit, price_per_unit, currency, source, last_updated)
            VALUES(UUID(), %s, %s, %s, %s, %s, %s, %s)
            ON DUPLICATE KEY UPDATE
              price_per_unit=VALUES(price_per_unit),
              currency=VALUES(currency),
              source=VALUES(source),
              last_updated=VALUES(last_updated)
        """, (ing_id, r.get("region"), r.get("unit"), price, r.get("currency"), r.get("source"), last_updated))

def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--host", default="127.0.0.1")
    ap.add_argument("--user", default="root")
    ap.add_argument("--password", default="")
    ap.add_argument("--database", default="bepviet")
    ap.add_argument("--csvdir", default="data_csv")
    ap.add_argument("--skip-prices", action="store_true", help="Bỏ qua nạp prices.csv")
    args = ap.parse_args()

    conn = mysql.connect(host=args.host, user=args.user, password=args.password, database=args.database)
    cur = conn.cursor()

    # Ensure aux tables
    ensure_aux_tables(cur)

    # Read CSVs
    units = read_csv(f"{args.csvdir}/units.csv")
    convs = read_csv(f"{args.csvdir}/unit_conversions.csv")
    ings  = read_csv(f"{args.csvdir}/ingredients.csv")
    aliases = read_csv(f"{args.csvdir}/ingredient_aliases.csv")
    recs  = read_csv(f"{args.csvdir}/recipes.csv")
    rec_ings = read_csv(f"{args.csvdir}/recipe_ingredients.csv")
    tags = read_csv(f"{args.csvdir}/tags.csv")
    rec_tags = read_csv(f"{args.csvdir}/recipe_tags.csv")
    prices = read_csv(f"{args.csvdir}/prices.csv")

    # Upserts core
    upsert_units(cur, units)
    upsert_unit_conversions(cur, convs)
    ing_map = upsert_ingredients(cur, ings)
    upsert_ing_key_map(cur, ing_map)
    upsert_aliases(cur, ing_map, aliases)
    rec_map = upsert_recipes(cur, recs)
    upsert_recipe_ingredients(cur, ing_map, rec_map, rec_ings)
    upsert_tags(cur, tags)
    upsert_recipe_tags(cur, rec_map, rec_tags)

    # Prices
    if (not args.skip_prices) and prices:
        upsert_prices(cur, ing_map, prices)

    conn.commit()
    cur.close(); conn.close()
    print("[DONE] Loaded CSVs into MySQL (including prices.csv).")

if __name__ == "__main__":
    main()
