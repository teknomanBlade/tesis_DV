using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ScreenGO : IScreen
{
    Dictionary<Behaviour, bool> _before;

    public Transform root;

    public ScreenGO(Transform root)
    {
        _before = new Dictionary<Behaviour, bool>();

        this.root = root;

        foreach(var b in root.GetComponentsInChildren<Behaviour>())
        {

        }
    }

    public void Activate()
    {
        foreach(var keyValue in _before)
        {
            if(keyValue.Key != null)
                keyValue.Key.enabled = keyValue.Value;
        }

        _before.Clear();
    }

    public void Deactivate()
    {
        foreach(var b in root.GetComponentsInChildren<Behaviour>())
        {
            _before[b] = b.enabled;

            if(b != root.GetComponentInChildren<CapsuleCollider2D>())
            {
                b.enabled = false;
            }
        }
    }

    public string Free()
    {
        GameObject.Destroy(root.gameObject);
        return " ";
    }
}