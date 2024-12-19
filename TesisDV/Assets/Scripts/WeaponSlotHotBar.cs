using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class WeaponSlotHotBar : WeaponSlot
{
    public Animator Animator;
    // Start is called before the first frame update
    void Start()
    {
        Animator = GetComponent<Animator>();
        HideWeaponSlotHotBar(true);
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
