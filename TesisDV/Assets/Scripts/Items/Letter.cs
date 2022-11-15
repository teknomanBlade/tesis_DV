using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Letter : Item
{
    private Animator _anim;
    [SerializeField]
    private GameObject letterCanvas;
    private bool IsOpened { get; set; }
    // Start is called before the first frame update
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

    public void ShowLetter()
    {
        letterCanvas.SetActive(true);
    }
    public void HideLetter()
    {
        letterCanvas.SetActive(false);
    }

    public override void Interact()
    {
        if (IsOpened)
        {
            _anim.SetBool("IsOpened", true);
            IsOpened = false;
        }
        else
        {
            _anim.SetBool("IsOpened", false);
            IsOpened = true;
        }
    }
    public void OpenLetterSound()
    {
        GameVars.Values.soundManager.PlaySoundAtPoint("LetterOpen", transform.position, 0.8f);
    }
    public void CloseLetterSound()
    {
        GameVars.Values.soundManager.PlaySoundAtPoint("LetterClose", transform.position, 0.8f);
    }
}
