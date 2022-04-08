using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[CreateAssetMenu]
    public class CraftingRecipe : ScriptableObject
    {
        public List<ItemAmount> materials;
        public List<ItemAmount> results;

        public bool CanCraft(Inventory inventory)
        {
            foreach(ItemAmount itemAmount in materials)
            {
                if(inventory.ItemCount(itemAmount.item) < itemAmount.amount)
                {
                    Debug.Log("No Puede");
                    return false;
                    
                }
            }
            Debug.Log("Puede");
            return true;           
        }

        public void Craft(Inventory inventory)
        {
            if(CanCraft(inventory))
            {
                foreach(ItemAmount itemAmount in results)
                {
                    for (int i = 0; i < itemAmount.amount; i++)
                    {
                        GameObject aux = Instantiate(itemAmount.baseballMachinePrefab);
                        Debug.Log("Si");
                    }
                }
            }
        }
    }
    
[Serializable]
public struct ItemAmount
{
    public InventoryItem item;
    public int amount;

    public GameObject baseballMachinePrefab;

    
}

   


