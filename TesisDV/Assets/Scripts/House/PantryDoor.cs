using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PantryDoor : Item
{
    private Animator _anim;
    private bool IsOpened { get; set; }
    // Start is called before the first frame update
    void Start()
    {
        IsOpened = true;
        _anim = GetComponent<Animator>();
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
            GameVars.Values.soundManager.PlaySoundAtPoint("OpenDoor", transform.position, 0.8f);
            IsOpened = false;
        }
        else
        {
            _anim.SetBool("IsOpened", false);
            GameVars.Values.soundManager.PlaySoundAtPoint("CloseDoor", transform.position, 0.8f);
            IsOpened = true;
        }
    }
}
