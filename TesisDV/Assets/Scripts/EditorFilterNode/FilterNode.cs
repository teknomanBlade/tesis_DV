using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class FilterNode 
{
    public Rect myRect;
    public string nodeName;
    public FilterNode previous;
    public List<FilterNode> connected;
    public string nodeToInteractName = "";

    private bool _overNode;

    public FilterNode(float x, float y, float width, float height, string name)
    {
        myRect = new Rect(x, y, width, height);
        connected = new List<FilterNode>();
        nodeName = name;
    }

    public void CheckMouse(Event cE, Vector2 pan)
    {
        _overNode = myRect.Contains(cE.mousePosition - pan);
    }

    public bool OverNode
    { get { return _overNode; } }
}
