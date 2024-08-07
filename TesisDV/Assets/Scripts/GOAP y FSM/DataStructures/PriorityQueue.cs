using System;
using System.Collections.Generic;
using System.Collections;
using Unity;
using UnityEngine;
using System.Linq;

public class PriorityQueue<T>
{
    private List<WeightedNode<T>> _queue = new List<WeightedNode<T>>();

    public void Enqueue(WeightedNode<T> element)
    {
        _queue.Add(element);
        _queue = _queue.OrderBy(n => n.Weight).ToList(); // Ordena la cola para garantizar que el nodo con menor peso esté al frente
    }

    public WeightedNode<T> Dequeue()
    {
        if (IsEmpty) throw new InvalidOperationException("Queue is empty");
        var min = _queue.First();
        _queue.RemoveAt(0);
        return min;
    }

    public bool IsEmpty => !_queue.Any();
}
