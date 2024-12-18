using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PriorityQueue
{
    private Dictionary<Node, float> _allNodes = new Dictionary<Node, float>();

    public void Put(Node k, float v)
    {
        if (_allNodes.ContainsKey(k)) _allNodes[k] = v;
        else _allNodes.Add(k, v);
    }

    public int Count()
    {
        return _allNodes.Count;
    }

    public Node Get()
    {
        Node n = null;
        foreach (var item in _allNodes)
        {
            if (n == null) n = item.Key;
            if (item.Value < _allNodes[n]) n = item.Key;
        }
        _allNodes.Remove(n);

        return n;
    }
}