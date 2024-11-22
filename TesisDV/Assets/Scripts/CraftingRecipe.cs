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
        Vector3 auxVector;

        [Serializable]
        public struct ItemAmount
        {
            //public InventoryItem item;
            public int craftingID;
            public int amount;
            //public int wittValue; No se usan Witts para construir trampas.
            public Sprite itemImage;
            public GameObject trapPrefab;
        }
        
        public bool HasBaseballTrapItems(Inventory inventory)
        {
            return inventory.ContainsID(5, 1) && inventory.ContainsID(2, 1) && inventory.ContainsID(8, 1);
        }
        public bool HasSlowTrapItems(Inventory inventory)
        {
            return inventory.ContainsID(4, 1);
        }
        public bool HasMicrowaveForceFieldGeneratorItems(Inventory inventory)
        {
            return inventory.ContainsID(2, 1) && inventory.ContainsID(12, 1);
        }
        public bool HasTeslaCoilGeneratorItems(Inventory inventory)
        {
            return inventory.ContainsID(2, 1) && inventory.ContainsID(13, 1) && inventory.ContainsID(17, 1);
        }
        public bool HasElectricTrapItems(Inventory inventory)
        {
            return inventory.ContainsID(2, 1) && inventory.ContainsID(9, 1) && inventory.ContainsID(10, 1);
        }
        public bool HasFERNPaintballMinigunItems(Inventory inventory)
        {
            return inventory.ContainsID(2, 1) && inventory.ContainsID(7, 1) && inventory.ContainsID(16, 1);
        }

        public bool CanCraft(Inventory inventory)
        {
            _inventory = inventory;
            foreach (ItemAmount itemAmount in materials)
            {
                if(!inventory.ContainsID(itemAmount.craftingID, itemAmount.amount)) //|| !inventory.HasEnoughWitts(itemAmount.wittValue)) No se usan Witts para construir trampas.
                {
                    return false;
                }
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
                        _player = GameObject.Find("Player").GetComponent<Player>();
                        
                        if(buildAmount == 0)
                        {
                            //GameObject aux = Instantiate(itemAmount.trapPrefab, _player.GetPrefabPlacement(), Quaternion.Euler(-90f,0f,90f));
                            //GameObject aux = Instantiate(itemAmount.trapPrefab, _player.GetPrefabPlacement(), Quaternion.identity);
                            _player.SwitchIsCrafting();
                            GameObject aux = Instantiate(itemAmount.trapPrefab, GameVars.Values.GetPlayerPrefabPlacement(), Quaternion.identity);

                            if(aux.GetComponent<StaticBlueprint>())
                            {
                                aux.GetComponent<StaticBlueprint>().SpendMaterials(true);
                                aux.GetComponent<StaticBlueprint>().CanBeCancelled(true);
                            }
                            else
                            {
                                aux.GetComponent<Blueprint>().SpendMaterials(true);
                                aux.GetComponent<Blueprint>().CanBeCancelled(true);
                            }
                            
                            aux.transform.eulerAngles = new Vector3(aux.transform.eulerAngles.x, GameVars.Values.GetPlayerCameraRotation(), aux.transform.eulerAngles.z);
                        }
                        buildAmount++;
                    }                    
                }
            }
        }

        public void RemoveItemsAndWitts()
        {
            foreach(ItemAmount itemAmount in materials)
            {
                for(int i = 0; i < itemAmount.amount; i++)
                {
                    _inventory.RemoveItemID(itemAmount.craftingID, itemAmount.amount);
                }
            }
        }

        public void RestoreBuildAmount()
        {
            buildAmount = 0;
        }
    }
    


   


