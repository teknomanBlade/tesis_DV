using System.ComponentModel;
using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[CreateAssetMenu]
    public class CraftingRecipe : ScriptableObject
    {
        public List<ItemAmount> materials;
        Player _player;
        private Inventory _inventory;
        public int buildAmount = 0;
        public List<ItemAmount> results;
        public Vector3 auxVector;

        [Serializable]
        public struct ItemAmount
        {
            //public InventoryItem item;
            public int craftingID;
            public int amount;
            public GameObject baseballMachinePrefab;
        }

        public bool CanCraft(Inventory inventory)
        {
            _inventory = inventory;
            foreach (ItemAmount itemAmount in materials)
            {
                
                if(!inventory.ContainsID(itemAmount.craftingID))
                {
                    return false;
                }

                /* if(inventory.ItemCount(itemAmount.item) < itemAmount.amount)
                {
                    Debug.Log("Hola: " + itemAmount.item + itemAmount.amount);
                    return false;
                } */
            }
            return true;           
        }

        public void Craft(Inventory inventory)
        {
            if (CanCraft(inventory))
            {
                
                /* foreach(ItemAmount itemAmount in materials)
                {
                    for(int i = 0; i < itemAmount.amount; i++)
                    {
                        inventory.RemoveItemID(itemAmount.craftingID);
                    }
                } */

                foreach(ItemAmount itemAmount in results)
                {
                    for (int i = 0; i < itemAmount.amount; i++)
                    {
                        _player = GameObject.Find("Player").GetComponent<Player>();
                        
                        if(buildAmount == 0)
                        {
                            GameObject aux = Instantiate(itemAmount.baseballMachinePrefab, _player.GetPrefabPlacement(), Quaternion.Euler(-90f,0f,0f));
                        }
                        buildAmount++;
  
                        //auxVector = new Vector3(_player.GetPrefabPlacement().x, 1 ,_player.GetPrefabPlacement().z);
                        //GameObject aux = Instantiate(itemAmount.baseballMachinePrefab, _player.GetPrefabPlacement(), Quaternion.Euler(0, -90, 65.358f));
                        //GameObject aux = Instantiate(itemAmount.baseballMachinePrefab, auxVector, Quaternion.Euler(-90f,0f,0f));
                        //Destroy(aux.GetComponent<InventoryItem>());
                    }                    
                }
            }
        }

        public void RemoveItems()
        {
            foreach(ItemAmount itemAmount in materials)
                {
                    for(int i = 0; i < itemAmount.amount; i++)
                    {
                        _inventory.RemoveItemID(itemAmount.craftingID);
                    }
                }
        }

        public void RestoreBuildAmount()
        {
            buildAmount = 0;
        }
    }
    


   


