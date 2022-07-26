using System.Collections;
using System.Collections.Generic;
using System.Linq;
using UnityEngine;

[CreateAssetMenu(fileName = "InventoryDatabase", menuName = "Inventory/InventoryDatabase")]
public class InventoryDatabase : ScriptableObject
{
    public List<ItemConfig> ItemDatabase = new List<ItemConfig>();

    public void Add(ItemConfig m)
    {
        ItemDatabase.Add(m);
        m.ID = ItemDatabase.IndexOf(m);
    }

    public void Remove(ItemConfig m)
    {
        ItemDatabase.Remove(m);
        m.ID = -1;
        Reseed();
    }

    public void RemoveAt(int index)
    {
        ItemConfig m = ItemDatabase[index];
        ItemDatabase.Remove(m);
    }

    public void RemoveAtReseed(int index)
    {
        ItemConfig m = ItemDatabase[index];
        ItemDatabase.Remove(m);
        Reseed();
    }

    public bool ContainsItem(string name)
    {
        return ItemDatabase.Any(x => x.ItemName == name);
    }

    public ItemConfig GetItemConfig(int index)
    {
        ItemConfig m = ItemDatabase[index];
        return m;
    }

    private void Reseed()
    {
        foreach (ItemConfig x in ItemDatabase)
        {
            x.ID = ItemDatabase.IndexOf(x);
        }
    }
}
