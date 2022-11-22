using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class FootLocker : Item
{
    private Animator _anim;
    public BoxCollider LidColllider;
    private bool IsOpened { get; set; }

    

    void Awake()
    {
        IsOpened = true;
        _anim = GetComponent<Animator>();
        itemType = ItemType.Interactable;
    }

    // Update is called once per frame
    void Update()
    {
        
    }

    public override void Interact()
    {
        if (IsOpened)
        {
            _anim.SetBool("IsOpened", true);
            GameVars.Values.HasOpenedTrunk = true;
            LidColllider.enabled = false;
            GameVars.Values.soundManager.PlaySoundAtPoint("FootLockerOpen", transform.position, 0.8f);
            IsOpened = false;
        }
        else
        {
            LidColllider.enabled = true;
            GameVars.Values.HasOpenedTrunk = false;
            _anim.SetBool("IsOpened", false);
            IsOpened = true;
        }
    }

    public void CloseLockerDoorSound()
    {
        GameVars.Values.soundManager.PlaySoundAtPoint("FootLockerClose", transform.position, 0.8f);
    }
}
