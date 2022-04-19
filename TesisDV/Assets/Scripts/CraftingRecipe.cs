using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[CreateAssetMenu]
    public class CraftingRecipe : ScriptableObject
    {
        public List<ItemAmount> materials;
        Player _player;
        public List<ItemAmount> results;
        public InventoryItem itemRemoved;
        public Vector3 auxVector;

        public bool CanCraft(Inventory inventory)
        {
            foreach (ItemAmount itemAmount in materials)
            {
                
                if(inventory.ItemCount(itemAmount.item) < itemAmount.amount)
                {
                    Debug.Log(itemAmount.item);
                    return false;
                    
                }
                itemRemoved = itemAmount.item;
            }
            return true;           
        }

        public void Craft(Inventory inventory)
        {
            if (CanCraft(inventory))
            {
                foreach(ItemAmount itemAmount in results)
                {
                    for (int i = 0; i < itemAmount.amount; i++)
                    {
                        inventory.RemoveItem(itemRemoved);
                        _player = GameObject.Find("Player").GetComponent<Player>();
                        Debug.Log("Soy io " + _player.GetPrefabPlacement());
                         
                        auxVector = new Vector3(0, _player.transform.position.y + 4f, _player.transform.position.z + 4f);
                        //GameObject aux = Instantiate(itemAmount.baseballMachinePrefab, _player.GetPrefabPlacement(), Quaternion.identity);
                        GameObject aux = Instantiate(itemAmount.baseballMachinePrefab, auxVector, Quaternion.Euler(-90, 0f, 0f));
                        Destroy(aux.GetComponent<InventoryItem>());
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

   


