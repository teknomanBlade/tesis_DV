using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class WardrobeDoor : Door
{
    // Start is called before the first frame update
    void Awake()
    {
        _anim = GetComponent<Animator>();
        itemType = ItemType.Interactable;
    }

    public override void Interact()
    {
        StopAllCoroutines();
        if (IsLocked)
        {
            _anim.SetBool("IsBlocked", true);
            GameVars.Values.soundManager.PlaySoundAtPoint("LockedDoorTry_" + RandomSound(), transform.position, 0.4f);
            Invoke("SetBlockedFalse", 0.5f);
            return;
        }

        if (!IsOpened)
        {
            IsOpened = true;
            GameVars.Values.soundManager.PlaySoundAtPoint("OpenDoor", transform.position, 0.4f);
            _anim.SetBool("IsOpen", true);
        }
        else
        {
            IsOpened = false;
            GameVars.Values.soundManager.PlaySoundAtPoint("CloseDoor", transform.position, 0.4f);
            _anim.SetBool("IsOpen", false);
        }

    }
}
