using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class WeaponSlotHotBar : WeaponSlot
{
    public Animator Animator;
    public Player Player;
    public Inventory Inventory;
    // Start is called before the first frame update
    void Start()
    {
        Animator = GetComponent<Animator>();
        Player = GameVars.Values.Player;
        Player.OnWeaponChanged += OnPlayerWeaponChanged;
        Inventory = GameVars.Values.Inventory;
        
    }

    private void OnPlayerWeaponChanged(int weaponID)
    {
        var item = Inventory.GetWeaponItem(weaponID);
        SetItem(item);
    }

    // Update is called once per frame
    void Update()
    {
        
    }
    public override void ShowWeaponHotBar()
    {
        ShowWeaponSlotHotBar(true);
        HideWeaponSlotHotBar(false);
    }
    public void ShowWeaponSlotHotBar(bool show)
    {
        Animator.SetBool("IsShowing", show);
    }

    public void HideWeaponSlotHotBar(bool hide) 
    {
        Animator.SetBool("IsHiding", hide);
    }
}
